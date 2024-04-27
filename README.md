Lead Records Enrichment with Apollo API
Overview
This Salesforce Apex class, SingleEnrichmentApollo, facilitates lead records enrichment by querying Apollo's database via REST API. It's designed as a batchable class to process a large number of leads efficiently.

Purpose
The purpose of this class is to enhance lead records within Salesforce by fetching additional information from Apollo's database, such as contact details, company information, and technology stack.

How It Works
Querying Leads: The batch class starts by querying leads from Salesforce where the is_enriched__c field is not set to true.
Preparing Data: For each lead, relevant data (such as email, first name, last name, and company) is prepared for the API request.
API Request: The prepared data is serialized into JSON format and sent to Apollo's API endpoint (https://api.apollo.io/v1/people/match) using a POST request.
Processing Response: Upon receiving a response from Apollo's API, the class parses the JSON response. If a 'person' is found in the response, it extracts relevant information such as email, name, job title, and company details.
Updating Lead Records: The class then updates the corresponding lead records in Salesforce with the retrieved information, enriching them with additional details.
Batch Processing: This process is executed in batches to handle large volumes of leads efficiently.
Configuration
API Key: Ensure that the api_key field in the request body is valid. Replace 'M9lzg-xm37Q_ixMATO0W0Q' with your actual Apollo API key.
API Endpoint: The API endpoint is set to https://api.apollo.io/v1/people/match. Modify this if the endpoint changes in the future.
Field Mapping: Adjust the field mappings in the code as per your Salesforce instance's lead object structure.
Usage
Deploy: Deploy the SingleEnrichmentApollo class to your Salesforce org.
Schedule: Schedule the batch class to run at desired intervals to keep lead records up-to-date.
Notes
Ensure that Salesforce instances have the necessary outbound network access to communicate with Apollo's API endpoint.
Monitor debug logs for insights into API requests/responses and batch processing.

Created BY
[Prateek Joshi]
Contact Email
[trzprateeksfdc@gmail.com]
