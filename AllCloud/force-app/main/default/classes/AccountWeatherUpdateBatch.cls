global class  AccountWeatherUpdateBatch implements Database.Batchable<sObject> , Database.AllowsCallouts, Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Account_Current_Weather__c, BillingLatitude, BillingLongitude, FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Account> accToUpdate = new List<Account>();
        for(Account acc: scope) {
            String oldWeatherDescription = '';
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
                    if(description != null && description != '' && oldWeatherDescription != acc.Account_Current_Weather__c) accToUpdate.add(acc);
                }
            }
        }
        if(!accToUpdate.isEmpty()) update accToUpdate;
    }

    global void finish(Database.BatchableContext BC){

    }
}