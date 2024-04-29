global class SingleEnrichmentApollo implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global database.QueryLocator start(Database.BatchableContext bc) {
       
        return database.getQueryLocator('SELECT Email,Is_Apollo_Verified__c,FirstName,Phone,Website,is_enriched__c,LastName,technology_stack__c,JSON_Response__c,industry,annualRevenue,NumberOfEmployees,Linkedin_URL__c,Title,State,Country,City,Company FROM Lead where is_enriched__c !=true');
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        Map<String, Object> leadData = new Map<String, Object>();
        
        for (Lead leadRec : leadList) {
            if (leadRec.Email != null) {
                leadData.put('email', leadRec.Email);
            }
            if (leadRec.firstname != null) {
                leadData.put('first_name', leadRec.firstname);
            }
            if (leadRec.lastname != null) {
                leadData.put('last_name', leadRec.lastname);
            }
            if (leadRec.company != null) {
                leadData.put('organization_name', leadRec.company);
            }
        } 
        
        leadData.put('api_key', 'Your_Api_KEy');
        String finalJSONBody = JSON.serialize(leadData);
        System.debug('Request Body: ' + finalJSONBody);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.apollo.io/v1/people/match');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(finalJSONBody);
        
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug('Response: ' + response.getBody());
            
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String leadJSonField = JSON.serialize(jsonResponse);
            system.debug('jsonResponse: '+ jsonResponse);
            
            if (jsonResponse.containsKey('person')) {
                Map<String, Object> person = (Map<String, Object>) jsonResponse.get('person');
                String email = (String) person.get('email');
                String firstName = (String) person.get('first_name');
                String lastName = (String) person.get('last_name');
                String linkedinUrl = (String) person.get('linkedin_url');
                String title = (String) person.get('title');
                String state = (String) person.get('state');
                String city = (String) person.get('city');
                String country = (String) person.get('country');
                integer annualRevenue = (integer) person.get('annualRevenue');
                for (Lead leadRec : leadList) {
                    if (leadRec.Email == email) {
                        leadRec.FirstName = firstName;
                        leadRec.LastName = lastName;
                        leadRec.Linkedin_URL__c = linkedinUrl;
                        leadRec.title = title;
                        leadRec.State = state;
                        leadRec.Country = country;
                        leadRec.City = city;
                        leadrec.leadsource = 'Apollo';
                        leadrec.JSON_Response__c = leadJSonField;
                        if (person.containsKey('departments')) {
                            Object departmentsObj = person.get('departments');
                            if (departmentsObj instanceof List<Object>) {
                                List<Object> departmentsList = (List<Object>)departmentsObj;
                                List<String> departments = new List<String>();
                                for (Object obj : departmentsList) {
                                    if (obj instanceof String) {
                                        departments.add((String)obj);
                                    }
                                }
                                String departmentsField = String.join(departments, ',');
                                leadRec.Department__c = departmentsField;
                            }
                        }
                        
                        if (person.containsKey('organization')) {
                            Map<String, Object> organization = (Map<String, Object>) person.get('organization');
                             Map<String, Object> contactResponse = (Map<String, Object>) person.get('contact');
                            if(contactResponse!=Null){
                                if (contactResponse.containsKey('sanitized_phone')) {
                                if(contactResponse.get('sanitized_phone')!=null){
                                     leadRec.Phone = (String) contactResponse.get('sanitized_phone');
                               }
                               
                            }
                            }
                            
                            system.debug('organ: ' +organization);
                            if (organization.containsKey('name')) {
                                leadRec.Company = (String) organization.get('name');
                            }
                           /* if (organization.containsKey('facebook_url')) {
                                leadRec.Facebook_URL__c = (String) organization.get('facebook_url');
                            }*/
                           /* if (organization.containsKey('primary_phone')) {
                                Map<String, Object> primaryPhoneMap = (Map<String, Object>) organization.get('primary_phone');
                                if (primaryPhoneMap.containsKey('sanitized_number')) {
                                    leadRec.Phone = (String) primaryPhoneMap.get('sanitized_number');
                                }
                            }*/
                            if (organization.containsKey('annual_revenue')) {
                                leadRec.annualrevenue = (decimal) organization.get('annual_revenue');
                            }
                            if (organization.containsKey('estimated_num_employees')) {
                                leadRec.NumberOfEmployees = (integer) organization.get('estimated_num_employees');
                            }
                            if (organization.containsKey('industry')) {
                                leadRec.industry = (string) organization.get('industry');
                            }
                            if (organization.containsKey('website_url')) {
                                leadRec.Website = (string) organization.get('website_url');
                            }
                            if (organization.containsKey('website_url')) {
                                leadRec.Website = (string) organization.get('website_url');
                            }
                            if (organization.containsKey('technology_names')) {
                                Object techNamesObj = organization.get('technology_names');
                                if (techNamesObj instanceof List<Object>) {
                                    List<Object> techNamesList = (List<Object>)techNamesObj;
                                    List<String> technologyNames = new List<String>();
                                    for (Object obj : techNamesList) {
                                        if (obj instanceof String) {
                                            technologyNames.add((String)obj);
                                        }
                                    }
                                    String leadTechnologyStackField = String.join(technologyNames, ',');
                                    leadRec.Technology_Stack__c = leadTechnologyStackField;
                                }
                            }
                            
                        }   
                        
                        break; 
                    }
                }
            } else {
                System.debug('No "person" found in the response.');
            }
            
            update leadList;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug(bc);
    }
}
