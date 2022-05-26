public with sharing class AccountDetail {
    public AccountDetail() {

    }

    @AuraEnabled
    public static ResponseClass getAccountDetail(String accId){
        ResponseClass response = new ResponseClass();
        Account acc = new Account();
        String oldWeatherDescription = '';
        try {
            system.debug('accId' + accId);
            acc = [SELECT Id, Account_Current_Weather__c, BillingLatitude, BillingLongitude, BillingAddress, BillingCity, BillingStreet, 
                    BillingState, BillingPostalCode, BillingCountry 
                    FROM Account WHERE Id =:accId];
            oldWeatherDescription = acc.Account_Current_Weather__c;
            if(acc.BillingLatitude != null && acc.BillingLongitude != null){
                String calloutURI = 'https://api.openweathermap.org/data/2.5/onecall?';
                calloutURI += 'lat=' + acc.BillingLatitude;
                calloutURI += '&lon='+ acc.BillingLongitude;
                calloutURI += '&exclude=hourly,daily&appid=ee27a8a77bc39181b57d3dc48934d5cd';

                System.debug('calloutURI::' + calloutURI);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(calloutURI);
                request.setMethod('GET');
                HttpResponse resp = http.send(request);
                String description = '';
                // If the request is successful, parse the JSON response.
                if(resp.getStatusCode() == 200) {
                    // Deserialize the JSON string into collections of primitive data types.
                    Map<String, Object> results = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    // Cast the values in the 'animals' key as a list
                    Map<String, Object> current = (Map<String, Object>) results.get('current');
                    List<Object> weather = (List<Object>) current.get('weather');
                    for(Object obj : weather) {
                        Map<String, Object> myMap =  (Map<String, Object>)obj;
                        System.debug('obj::' + (String)myMap.get('description'));
                        description = (String)myMap.get('description');
                        if(description != null && description != '') {
                            acc.Account_Current_Weather__c = description;
                            break;
                        }
                    }
                    if(description != null && description != '' && oldWeatherDescription != acc.Account_Current_Weather__c) update acc;
                    response.acc = acc;
                    response.message = 'Update with success';
                }
            } else {
                response.acc = acc;
                response.message = 'Latitude or Longitude is missing';
            }
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            response.acc = acc;
            response.message = 'Update Failed. This is the error' + e.getMessage();
        }
        return response;
    }

    public class ResponseClass {
        @AuraEnabled
        public Account acc { get; set; }
        @AuraEnabled
        public String message {get; set; }
    }
}
