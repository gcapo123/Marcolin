/**
 * @description Demonstrates how to make REST calls to ConnectApi.CommerceSearch class
 * to perform Search and Category browsing for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public with sharing class B2BSearchControllerSample {
    // Cached API version of this apex class.
    private static Decimal apiVersionApexClass = [
        SELECT ApiVersion
        FROM ApexClass
        WHERE Name = 'B2BSearchControllerSample'
        LIMIT 1
    ]
    .ApiVersion;

    /**
     * @description Demonstrates how to call ConnectApi.CommerceSearch.productSearch
     * @param communityId The Id of the community from which the call originated
     * @param searchQuery The search query parameters which includes searchTerm, categoryId, refinements, page and includePrices
     * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     */
    @AuraEnabled(cacheable=true)
    public static Object productSearch(
        String communityId,
        String searchQuery,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(
            communityId
        );

        HttpRequest httpRequest = new HttpRequest();
        Map<String,Object> response;

        // As per the Salesforce documentation
        // "By security policy, sessions created by Lightning components aren’t
        //  enabled for API access. This prevents even your Apex code from
        //  making API calls to Salesforce. Using a named credential for
        //  specific API calls allows you to carefully and selectively bypass
        // this security restriction."
        // - https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/apex_api_calls.htm
        //
        // So the following section that takes the OAuth is commented out and
        // used the named credential callout 'CallMeBack' below.
        // The steps to create named credentials are documented the repo here
        // docs/NamedCredentials.md

        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String apiUrl = '/services/data/v' + apiVersionApexClass + '/commerce/webstores/' + webstoreId + '/search/product-search';
        httpRequest.setEndpoint(baseUrl + apiUrl);

        /*httpRequest.setMethod('POST');
        httpRequest.setHeader(
            'Content-Type',
            'application/json;  charset=utf-8'
        );
        httpRequest.setEndpoint(
            'callout:CallMeBack/services/data/v' +
            apiVersionApexClass +
            '/commerce/webstores/' +
            webstoreId +
            '/search/product-search'
        );*/

        httpRequest.setBody(searchQuery);

        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();

            if (statusCode >= 200 && statusCode <= 204) {
                response = (Map<String,Object>)JSON.deserializeUntyped(httpResponse.getBody());
            } else {
                //System.debug(' httpResponse ' + httpResponse.getBody());
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
            throw e;
        }
        List<Map<String,Object>> facets = new List<Map<String,Object>>();
        for (Object instance : (List<Object>)response.get('facets')){
            facets.add((Map<String, Object>)instance);
        }
        //System.debug(facets);
        List<String> fieldsToGet = new List<String>();
        Map<String,List<Object>> possibleVarAtt = new Map<String,List<Object>>();
        for(Map<String,Object> o : facets){
            
            if((String)o.get('attributeType') == 'ProductAttribute'){
                fieldsToGet.add((String)o.get('nameOrId'));
                List<Object> ll = (List<Object>)o.get('values');
                possibleVarAtt.put((String)o.get('nameOrId'),ll);
            }
        }
        Map<String,Object> productsPage = (Map<String,Object>)response.get('productsPage');
        List<Map<String,Object>> prods = new List<Map<String,Object>>();
        for(Object instance : (List<Object>)productsPage.get('products')){
            prods.add((Map<String, Object>)instance);
        }
        List<Map<String,Object>> newProds = new List<Map<String,Object>>();
        List<String> prodIds = new List<String>();
        for(Map<String,Object> o : prods){
            prodIds.add((String)o.get('id'));
        }
        Map<String,List<VariationProd>> resultingVariations = getVariationProducts(prodIds,fieldsToGet);
        Map<String,Object> allMedias = getAllMedia(prodIds,communityId);
        for(Map<String,Object> o : prods){
            Map<String,Object> itsMedias = new Map<String,Object>();
            for(String key : allMedias.keySet()){
                if(key.startsWith((String)o.get('id'))){
                    String newK = key.split('_')[1];
                    itsMedias.put(newK,allMedias.get(key));
                }
            }
            Map<String,Object> newO = new Map<String,Object>();
            newO.put('id',o.get('id'));
            newO.put('fields',o.get('fields'));
            newO.put('name',o.get('name'));
            newO.put('defaultImage',o.get('defaultImage'));
            newO.put('prices',o.get('prices'));
            newO.put('productClass',o.get('productClass'));
            newO.put('purchaseQuantityRule',o.get('purchaseQuantityRule'));
            newO.put('variationAttributeSet',o.get('variationAttributeSet'));
            if(resultingVariations == null || resultingVariations.get((String)o.get('id'))==null){
                newO.put('variationProducts', null);   
                newO.put('variationList',null); 
            }else{
                List<VariationProd> vppL = resultingVariations.get((String)o.get('id'));
               
                List<Map<String,Object>> varPmap = new List<Map<String,Object>>();
                for(VariationProd vp : vppL){
                   
                    Map<String,Object> el = new Map<String,Object>();
                    el.put('id',(Object)vp.id);
                    el.put('attValues',(Object)vp.attValues);
                    varPmap.add(el);
                }
                newO.put('variationProducts', varPmap);
                Map<String,Object> resVariationList = getVariationsListForP(vppL,possibleVarAtt,itsMedias);
                newO.put('variationList',resVariationList);
            }
            
            newProds.add(newO);
            
        }
        
        productsPage.put('products',newProds);
        
        Map<String,Object> resultResponse = new Map<string,Object>();
        resultResponse.put('categories',response.get('categories'));
        resultResponse.put('facets',facets);
        resultResponse.put('locale',response.get('locale'));
        resultResponse.put('productsPage',productsPage);
        
        return (Object)resultResponse;
    }

    public static Map<String,Object> getVariationsListForP(List<VariationProd> vppL,Map<String,List<Object>> possibleVarAtt,Map<String,Object> itsMedias){
        Map<String,Object> result = new Map<String,Object>();
        for(String key : possibleVarAtt.keySet()){
            //key = key
            //value -> [{value:blue,label:blue},{},{}]
            List<Map<String,Object>> values = new List<Map<String,Object>>();
            for(Object oo : possibleVarAtt.get(key)){
                Map<String,Object> o = (Map<String,Object>)oo;
                //loop over the values of single variation
                Map<String,Object> singleEl = new Map<String,Object>();
                for(VariationProd vp :vppL){
                    if(vp.attValues.get(key) == (String)o.get('nameOrId')){
                        singleEl.put('value',(Object)o.get('nameOrId'));
                        singleEl.put('label',(Object)o.get('nameOrId'));
                        if(itsMedias.containsKey(vp.attValues.get(key))){
                            singleEl.put('image',itsMedias.get(vp.attValues.get(key)));
                        }
                        
                        values.add(singleEl);
                        break;
                    }
                }
            }
            //now in values I have the full list of possible values.
            result.put(key,values);
        }
        return result;
        
    }
    
    
    public static Map<String,List<VariationProd>> getVariationProducts(List<String> parentId, List<String> attributes){
        try {
           
            String queryParams = '';
           
            for (String el : attributes){
                queryParams = queryParams+','+el;
            }

            String idsParents = '(';
            for(Integer i =0 ;i<parentId.size();i++){
                String el = parentId[i];
                idsParents = idsParents+'\''+el+'\'';
                if(i < parentId.size()-1){
                   idsParents = idsParents+',';
                }else{
                    idsParents = idsParents+')';
                }
            }
           
            //System.debug('SELECT VariantParentId,ProductId'+queryParams+' FROM ProductAttribute WHERE VariantParentId IN '+idsParents);
            List<ProductAttribute> pas = Database.query('SELECT VariantParentId,ProductId'+queryParams+' FROM ProductAttribute WHERE VariantParentId IN '+idsParents);
            //System.debug(pas);
            Map<String,List<VariationProd>> result = new Map<String,List<VariationProd>>();
            if(pas.size()>0){
                //List<String> ids = new List<String> ();
              
                for(ProductAttribute p : pas){
                    //ids.add(p.ProductId);
                    VariationProd vp = new VariationProd();
                    vp.id = p.ProductId;
                    vp.attValues = new Map<String,String>();
                    for(String a : attributes){
                        
                        vp.attValues.put(a,(String)p.get(a));
                       
                    }
                    List<VariationProd> l;
                    if (! result.containsKey(p.VariantParentId)){
                        l = new List<VariationProd>();
                    }else{
                        l = result.get(p.VariantParentId);
                    }
                    l.add(vp);
                    
                    result.put(p.VariantParentId,l);
                }

                
                // List<Product2> prods= [SELECT Name FROM Product2 WHERE Id IN :ids];
                // for(Product2 p:prods){
                //     for(VariationProd vp : result){
                //         if(vp.id == p.Id){
                //             vp.name = p.Name;
                //         }
                //     }
                // }
                
                return result;
            }
            return null;
            
        } catch (Exception e) {
            return null;
        }
    }

    public static Map<String,Object> getAllMedia(List<String> productIds,String communityId){
        List<ProductMedia> productMedia = [SELECT ElectronicMediaId,ProductId FROM ProductMedia WHERE ProductId IN :productIds];
        List<String> mediaIds = new List<String>();
        Map<String,Object> result = new Map<String,Object>();
        Map<String,String> elpr = new Map<String,String>();
        for(ProductMedia pm : productMedia){
                mediaIds.add(pm.ElectronicMediaId);
                elpr.put(pm.ElectronicMediaId,pm.ProductId);
        }
            
        ConnectApi.ManagedContentVersionCollection mediaList = ConnectApi.ManagedContent.getManagedContentByIds(communityId, mediaIds,null,null,null,null,true);
        for(ConnectApi.ManagedContentVersion media : mediaList.items){
                
                ConnectApi.ManagedContentTextNodeValue altText = (ConnectApi.ManagedContentTextNodeValue)media.contentNodes.get('altText');
                if(altText != null){
                    String color = altText.value;
                    String pr = (String) elpr.get(media.managedContentId);
                    result.put(pr+'_'+color,media.contentNodes.get('source'));
                }
                
                
        }
        System.debug(result);
        return result;
    }

    public class VariationProd{
        public String name;
        public String id;
        public Map<String,String> attValues;
    }
}
