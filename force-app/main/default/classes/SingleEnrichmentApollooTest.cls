@isTest
private class SingleEnrichmentApollooTest {
    @isTest
    static void testBatch() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead leady = new Lead(
                FirstName = 'TestFirst',
                LastName = 'TestLast' ,
                Email = 'sam.maxwell@executivewg.com',
                company ='test',
                Is_Apollo_Verified__c =true
            );
            testLeads.add(leady);
        
        insert testLeads;

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start the batch
        Test.startTest();
        
        Database.executeBatch(new SingleEnrichmentApollo(),200);
        Test.stopTest();

        // Verify updated leads
        List<Lead> updatedLeads = [SELECT Id, FirstName, LastName, Linkedin_URL__c, Title, State, Country,LeadSource,City, Company,Phone_New__c, annualrevenue, NumberOfEmployees, industry, Website FROM Lead where email ='sam.maxwell@executivewg.com'];
        System.assertEquals(1, updatedLeads.size());
      for (Lead lead : updatedLeads) {
          

            // Verify organization details
            if (lead.Company != null) {
               
                
            }
        }
      
    }

    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"person": {"email": "sam.maxwell@executivewg.com","departments":["test Departments"],"contact": {"sanitized_phone": "+441245476666"}, "first_name": "John", "last_name": "Doe", "linkedin_url": "https://www.linkedin.com/in/johndoe", "title": "CEO", "state": "CA", "city": "San Francisco", "country": "USA", "annualRevenue": 1000000, "organization": {"name": "Acme Inc.", "facebook_url": "https://www.facebook.com/acme", "primary_phone": {"sanitized_number": "(123) 456-7890"}, "annual_revenue": 2000000, "estimated_num_employees": 50, "industry": "Technology", "website_url": "https://www.acme.com","technology_names":["test TEchnology"]}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}