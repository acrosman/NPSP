/*
    Copyright (c) 2022, Salesforce.org
    All rights reserved.
   
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
   
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

/**
* @author Salesforce.org
* @date 2022
* @group Donation
* @description Unit Test Class for test the recurring donations controller and selector.
*/
@IsTest
public class RecurringDonationsController_TEST {
    
    /**
    * @author Salesforce.org
    * @date 2022
    * @description Method to test that the results are returned correctly
    */
    @IsTest
    private static void testInstanceRecurringDonationsService() {
        Test.startTest();
        RecurringDonationsService service = RecurringDonationsController.donationService;
        Test.stopTest();

        System.assertNotEquals(null, service, 'Should instance RecurringDonationsService');
    }

    /**
    * @author Salesforce.org
    * @date 2022
    * @description Method to test that the results are returned correctly
    */
    @IsTest
    private static void testGetData() {
        
        Account acc = new Account(
            Name = 'Test acc'
        );
        insert acc;

        Contact con = new Contact(
            LastName = 'Test con',
            AccountId = acc.ID
        );
        insert con;

        npe03__Recurring_Donation__c rDonation01 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Monthly',
            InstallmentFrequency__c = 1,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        npe03__Recurring_Donation__c rDonation02 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Yearly',
            InstallmentFrequency__c = 1,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        npe03__Recurring_Donation__c rDonation03 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = '1st and 15th',
            InstallmentFrequency__c = 1,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        npe03__Recurring_Donation__c rDonation04 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Monthly',
            InstallmentFrequency__c = 2,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        npe03__Recurring_Donation__c rDonation05 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Yearly',
            InstallmentFrequency__c = 2,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        npe03__Recurring_Donation__c rDonation06 = new npe03__Recurring_Donation__c(
            npe03__Amount__c = 100,
            npe03__Installment_Period__c = 'Weekly',
            InstallmentFrequency__c = 2,
            Day_of_Month__c = '23',
            npe03__Contact__c = con.ID
        );

        List<SObject> records = new List<SObject> {rDonation01,rDonation02,rDonation03,rDonation04,rDonation05,rDonation06};
        RecurringDonationsSelectorMock mock = new RecurringDonationsSelectorMock(records);
        RecurringDonationsService service = new RecurringDonationsService();
        service.selector = (RecurringDonationsSelector) Test.createStub(RecurringDonationsSelector.class, mock);
        RecurringDonationsController.donationService = service;
       
        Test.startTest();
        List<RecurringDonationsController.RecurringDonation> result = RecurringDonationsController.getData();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Recurring Donations should not be null');
    }

    public class RecurringDonationsSelectorMock implements System.StubProvider{
        
        private SObject[] objectsToReturn;
        
        public RecurringDonationsSelectorMock(SObject[] objectToReturn) {
            this.objectsToReturn = objectToReturn;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {

            if (stubbedMethodName.equals('getRecurringDonations')) {
                return objectsToReturn;
            }
            return objectsToReturn;
        }

    }
}