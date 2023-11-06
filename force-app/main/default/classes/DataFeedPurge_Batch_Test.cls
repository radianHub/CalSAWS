@isTest
private class DataFeedPurge_Batch_Test{

    @testSetup
    static void initialSetup() {

        //
       //crate datafeeed objects
       //set the status processed
    }
      
    @isTest 
    static void test_method_DataFeedPurge_Batch_Test() {
        
       
            Test.startTest();
                DataFeedPurge_Batch batch = new DataFeedPurge_Batch();
                SchedulableContext sc;
                batch.execute(sc);
            Test.stopTest();
    
    }

   

}