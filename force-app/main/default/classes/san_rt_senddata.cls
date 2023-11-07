/*
Class for custom REST API to update Service Activity and Notes.
URL: /services/apexrest/san/postdata
*/
@RestResource(urlMapping='/san/postdata')
global class san_rt_senddata {
    @HTTPPOST
    global static void SendEvents() {
        sa_wrapper objHttpResponse= new sa_wrapper();
        notes_wrapper NotobjHttpResponse= new notes_wrapper();
        String responseBody = '';
        RestRequest req = RestContext.request;
        Map<String,String> receivedHeader = req.headers;
        list<string> SA_Names = new list<string>();
        list<string> SuccessMsg = new list<string>();
        list<string> ErrorMsg = new list<string>();
        Launchpad__Enrollment__c leRec= new Launchpad__Enrollment__c();
        Note__c noteRec = new Note__c();
        list<Launchpad__Enrollment__c> UpdLeRec= new list<Launchpad__Enrollment__c>();
        list< Note__c> InsNotRec= new list< Note__c>();
        Map<string,Launchpad__Enrollment__c> LeMap = new Map<string,Launchpad__Enrollment__c>();
        RestResponse response = new RestResponse(); 
        response = RestContext.response;
        
        list<string> NoMatchStr = new list<string>();
        list<string> NoMatchNotes = new list<string>();
        account acc= new account();
        Database.SaveResult [] updateResult;
        Database.SaveResult [] InsResult;
        Database.SaveResult [] NotupdateResult;
        list<AC_Response.cls_res> clslst = new list<AC_Response.cls_res>();
        AC_Response.cls_res obj = new AC_Response.cls_res();
        AC_Response.cls_errors clserr = new AC_Response.cls_errors();
        list<AC_Response.cls_errors> claserr = new list<AC_Response.cls_errors>();
        list<string> Not_Names_Upd = new list<string>();
        list<string> NoMatchNotesUpd = new list<string>();
        list<note__c> UpdLeNotRec = new list<note__c>();
        Map<string,Note__c> LeNotMap = new Map<string,Note__c>();
        note__c  leNotRec = new note__c();
        
        
        try{
            if(receivedHeader.containsKey('Content-Type') && receivedHeader.get('Content-Type').toLowerCase() == 'application/json'){
                //start of updating Service activity record
                if(receivedHeader.containsKey('object') && (string.valueOf(receivedHeader.get('object'))).toUpperCase() == 'launchpad_enrollment'){
                    if(receivedHeader.containsKey('operation') && (string.valueOf(receivedHeader.get('operation'))).toUpperCase() == 'update'){
                        if(req.requestBody != null && string.isNotEmpty(req.requestBody.toString()))  
                        {
                            String requestBody = req.requestBody.toString();
                            objHttpResponse = sa_wrapper.parse(requestBody);
                            system.debug('objHttpResponse '+objHttpResponse.records);
                            if(objHttpResponse.records != null )
                            {
                                for(sa_wrapper.cls_records rec: objHttpResponse.records)
                                {
                                    system.debug('Rec '+rec.name);
                                    SA_Names.add('Enrollment-'+rec.name);
                                    
                                }
                            }//END OF objHttpResponse
                            
                            if(SA_Names.size() >0)
                            {
                                for(Launchpad__Enrollment__c rec: [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c, First_Day_of_Child_Care__c  from Launchpad__Enrollment__c
                                                                   where name =: sa_Names])
                                    LeMap.put(rec.name, rec);
                                system.debug('LeMap '+LeMap);
                                for(sa_wrapper.cls_records rec: objHttpResponse.records)
                                {
                                    if(LeMap.containskey('Enrollment-'+rec.name))
                                    {
                                        leRec= LeMap.get('Enrollment-'+rec.name);
                                        system.debug('leRec '+leRec);
                                        leRec.Child_Care_ID__c = rec.ChildCareID;
                                        leRec.Childcare_Referral_Status__c=rec.ChildcareReferralStatus;
                                        leRec.First_Day_of_Child_Care__c=rec.FirstDayofChildCare;
                                        UpdLeRec.add(leRec);
                                    }
                                    else
                                        NoMatchStr.add(rec.name);
                                    
                                }
                            }
                        }
                        if(UpdLeRec.size()> 0)
                        {
                            
                            updateResult =database.update(UpdLeRec,false);
                            //response.responseBody =  Blob.valueof(json.serialize(updateResult,true));
                            // response.responseBody =  Blob.valueof(json.serialize(updateResult,true));
                            for (Database.SaveResult sr : updateResult) {
                                obj = new AC_Response.cls_res();
                                // clserr = new AC_Response.cls_errors();
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    obj.success = true;
                                    obj.recordId = sr.getId();
                                    System.debug('Successfully updated service activity. ID: ' + sr.getId());
                                }
                                else {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        clserr = new AC_Response.cls_errors();
                                        claserr = new list<AC_Response.cls_errors>();
                                        obj.success = false;
                                        obj.recordId = sr.getId();
                                        clserr.statusCode =string.valueOf(err.getStatusCode());
                                        clserr.message = err.getMessage();
                                        clserr.fields = err.getFields();
                                        
                                        claserr.add(clserr);
                                        obj.errors =claserr;
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('SA fields that affected this error: ' + err.getFields());
                                    }
                                }
                                clslst.add(obj);
                                
                            }
                            
                        }
                        if(NoMatchStr.size() > 0)
                        {
                            System.debug('MATCHING_RECORDS_NOT_FOUND');  
                            obj = new AC_Response.cls_res();
                            clserr = new AC_Response.cls_errors();
                            claserr = new list<AC_Response.cls_errors>();
                            obj.success = false;
                            clserr.statusCode = 'MATCHING_RECORDS_NOT_FOUND';
                            clserr.message = 'Records does not exist in Salesforce for update.';
                            clserr.fields =NoMatchStr;// new list<string>{sa};
                            claserr.add(clserr);
                            obj.errors =claserr;
                            clslst.add(obj);
                        }
                        
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }
                    //Error when no Operation or invalid Operation.
                    if(!receivedHeader.containsKey('operation') || receivedHeader.get('operation').toLowerCase() != 'update')
                    {
                        system.debug('Error: Invalid operation header for launchpad_enrollment');
                        response.statusCode = 400;
                        obj = new AC_Response.cls_res();
                        clserr = new AC_Response.cls_errors();
                        claserr = new list<AC_Response.cls_errors>();
                        obj.success = false;
                        clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
                        clserr.message = 'Error: Invalid operation header for launchpad_enrollment';
                        claserr.add(clserr);
                        obj.errors =claserr;
                        clslst.add(obj);
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }
                    
                }// End of serrvice activity records
                
                //start of Insert/updating Notes activity record
                if(receivedHeader.containsKey('object') && (string.valueOf(receivedHeader.get('object'))).toUpperCase() == 'notes'){
                    if(receivedHeader.containsKey('operation') && (string.valueOf(receivedHeader.get('operation'))).toUpperCase() == 'insert'){
                        if(req.requestBody != null && string.isNotEmpty(req.requestBody.toString()))  
                        {
                            String requestBody = req.requestBody.toString();
                            NotobjHttpResponse = notes_wrapper.parse(requestBody);
                            system.debug('NotobjHttpResponse '+NotobjHttpResponse.records);
                            if(NotobjHttpResponse.records != null )
                            {
                                for(notes_wrapper.cls_records rec: NotobjHttpResponse.records)
                                {
                                    system.debug('Rec '+rec.ServiceActivityName);
                                    SA_Names.add('Enrollment-'+rec.ServiceActivityName);
                                    
                                }
                            }//END OF objHttpResponse
                            
                            if(SA_Names.size() >0)
                            {
                                for(Launchpad__Enrollment__c rec: [select id,name,Child_Care_ID__c ,Childcare_Referral_Status__c,First_Day_of_Child_Care__c from Launchpad__Enrollment__c
                                                                   where name =: sa_Names])
                                    LeMap.put(rec.name, rec);
                                system.debug('LeMap '+LeMap);
                                for(notes_wrapper.cls_records rec: NotobjHttpResponse.records)
                                {
                                    if(LeMap.containskey('Enrollment-'+rec.ServiceActivityName))
                                    {
                                        noteRec = new note__c();
                                        leRec= LeMap.get('Enrollment-'+rec.ServiceActivityName);
                                        system.debug('leRec '+leRec);
                                        noteRec.Service_Activity__c = leRec.id;
                                        noteRec.CC3_DateTime__c =rec.CC3DateTime;
                                        noteRec.CC3_UserName__c  =rec.CC3UserName;
                                        noteRec.Body__c  =rec.Body;
                                        noteRec.name = rec.Name;
                                        system.debug('noteRec '+noteRec);
                                        InsNotRec.add(noteRec);
                                    }
                                    else 
                                        NoMatchNotes.add(rec.ServiceActivityName);
                                }
                            }
                            system.debug('noteRec size'+InsNotRec.size());
                        }
                        if(InsNotRec.size()> 0)
                        {
                            InsResult =database.insert(InsNotRec,false);
                            for (Database.SaveResult sr : InsResult) {
                                obj = new AC_Response.cls_res();
                                // clserr = new AC_Response.cls_errors();
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    obj.success = true;
                                    obj.recordId = sr.getId();
                                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                                }
                                else {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        clserr = new AC_Response.cls_errors();
                                        claserr = new list<AC_Response.cls_errors>();
                                        obj.success = false;
                                        obj.recordId = sr.getId();
                                        clserr.statusCode =string.valueOf(err.getStatusCode());
                                        clserr.message = err.getMessage();
                                        clserr.fields = err.getFields();
                                        
                                        claserr.add(clserr);
                                        obj.errors =claserr;
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('Account fields that affected this error: ' + err.getFields());
                                    }
                                }
                                clslst.add(obj);
                                
                            }
                            
                        }
                        if(NoMatchNotes.size() > 0)
                        {
                            System.debug('MATCHING_RECORDS_NOT_FOUND');  
                            obj = new AC_Response.cls_res();
                            clserr = new AC_Response.cls_errors();
                            claserr = new list<AC_Response.cls_errors>();
                            obj.success = false;
                            clserr.statusCode = 'MATCHING_RECORDS_NOT_FOUND';
                            clserr.message = 'Parent Records does not exist in Salesforce for Insert.';
                            clserr.fields =NoMatchNotes;// new list<string>{sa};
                            claserr.add(clserr);
                            obj.errors =claserr;
                            clslst.add(obj);
                            
                        }
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }// End of notes Insert
                    //Error when no Opetation for Notes or Invalid Operation
                    if(!receivedHeader.containsKey('operation') ||(receivedHeader.get('operation').toLowerCase() != 'insert' && receivedHeader.get('operation').toLowerCase() != 'update'))
                    {
                        system.debug('Error: Invalid operation header for Notes');
                        response.statusCode = 400;
                        obj = new AC_Response.cls_res();
                        clserr = new AC_Response.cls_errors();
                        claserr = new list<AC_Response.cls_errors>();
                        obj.success = false;
                        clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
                        clserr.message = 'Error: Invalid operation header for Notes';
                        claserr.add(clserr);
                        obj.errors =claserr;
                        clslst.add(obj);
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }
                    //Notes update 
                    if(!receivedHeader.containsKey('operation') || (receivedHeader.get('operation').toLowerCase() != 'insert' && receivedHeader.get('operation').toLowerCase() != 'update') )
                    {
                        system.debug('Error: Invalid operation header for Notes');
                        response.statusCode = 400;
                        obj = new AC_Response.cls_res();
                        clserr = new AC_Response.cls_errors();
                        claserr = new list<AC_Response.cls_errors>();
                        obj.success = false;
                        clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
                        clserr.message = 'Error: Invalid operation header for Notes';
                        claserr.add(clserr);
                        obj.errors =claserr;
                        clslst.add(obj);
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }
                    //Notes update 
                    // 02/18 
                    if(receivedHeader.containsKey('operation') && (string.valueOf(receivedHeader.get('operation'))).toLowerCase() == 'update'){
                        if(req.requestBody != null && string.isNotEmpty(req.requestBody.toString()))  
                        {
                            
                            String requestBody = req.requestBody.toString();
                            NotobjHttpResponse = notes_wrapper.parse(requestBody);
                            system.debug('NotobjHttpResponse '+NotobjHttpResponse.records);
                            if(NotobjHttpResponse.records != null )
                            {
                                for(notes_wrapper.cls_records rec: NotobjHttpResponse.records)
                                {
                                    system.debug('Rec '+rec.Name);
                                    Not_Names_Upd.add(rec.Name);
                                    
                                }
                            }
                            //END OF objHttpResponse
                            
                            if(Not_Names_Upd.size() >0)
                            {
                                for(Note__c rec: [select id,name,Service_Activity__c ,CC3_DateTime__c,CC3_UserName__c,Body__c from Note__c
                                                  where name =: Not_Names_Upd])
                                    LeNotMap.put(rec.name, rec);
                                system.debug('LeMap '+LeMap);
                                for(notes_wrapper.cls_records rec: NotobjHttpResponse.records)
                                {
                                    if(LeNotMap.containskey(rec.name))
                                    {
                                        leNotRec= LeNotMap.get(rec.name);
                                        system.debug('leNotRec  '+leNotRec);
                                        // leNotRec.Service_Activity__c = leRec.id;
                                        leNotRec.CC3_DateTime__c =rec.CC3DateTime;
                                        leNotRec.CC3_UserName__c  =rec.CC3UserName;
                                        leNotRec.Body__c  =rec.Body;
                                        leNotRec.name = rec.Name;
                                        system.debug('leNotRec  '+leNotRec);
                                        
                                        UpdLeNotRec.add(leNotRec);
                                    }
                                    else
                                        NoMatchStr.add(rec.name);
                                    
                                }
                            }
                        }
                        if(UpdLeNotRec.size()> 0)
                        {
                            
                            NotupdateResult =database.update(UpdLeNotRec,false);
                            
                            for (Database.SaveResult sr : NotupdateResult) {
                                obj = new AC_Response.cls_res();
                                // clserr = new AC_Response.cls_errors();
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    obj.success = true;
                                    obj.recordId = sr.getId();
                                    System.debug('Successfully updated Note. ID: ' + sr.getId());
                                }
                                else {
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        clserr = new AC_Response.cls_errors();
                                        claserr = new list<AC_Response.cls_errors>();
                                        obj.success = false;
                                        obj.recordId = sr.getId();
                                        clserr.statusCode =string.valueOf(err.getStatusCode());
                                        clserr.message = err.getMessage();
                                        clserr.fields = err.getFields();
                                        
                                        claserr.add(clserr);
                                        obj.errors =claserr;
                                        System.debug('The following error has occurred.');                    
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        System.debug('SA fields that affected this error: ' + err.getFields());
                                    }
                                }
                                clslst.add(obj);
                                
                            }
                            
                        }
                        if(NoMatchStr.size() > 0)
                        {
                            System.debug('MATCHING_RECORDS_NOT_FOUND');  
                            obj = new AC_Response.cls_res();
                            clserr = new AC_Response.cls_errors();
                            claserr = new list<AC_Response.cls_errors>();
                            obj.success = false;
                            clserr.statusCode = 'MATCHING_RECORDS_NOT_FOUND';
                            clserr.message = 'Records does not exist in Salesforce for update.';
                            clserr.fields =NoMatchStr;// new list<string>{sa};
                            claserr.add(clserr);
                            obj.errors =claserr;
                            clslst.add(obj);
                        }
                        
                        response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                    }
                    
                    
                }
                // End of notes activity records
                
                //Error when No object Header or invalid object name being passed.
                if(!receivedHeader.containsKey('object') || (string.valueOf(receivedHeader.get('object'))).toUpperCase() != 'notes' && 
                   (string.valueOf(receivedHeader.get('object'))).toUpperCase() != 'launchpad_enrollment') {
                       system.debug('Error: Invalid object header');
                       response.statusCode = 400;
                       obj = new AC_Response.cls_res();
                       clserr = new AC_Response.cls_errors();
                       claserr = new list<AC_Response.cls_errors>();
                       obj.success = false;
                       clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
                       clserr.message = 'Error: Invalid object header';
                       claserr.add(clserr);
                       obj.errors =claserr;
                       clslst.add(obj);
                       response.responseBody =  Blob.valueof(json.serialize(clslst,false));
                   }
            } //ENd of receivedHeader
            
            //Error when no content-type or invalid content-type value
            if(!receivedHeader.containsKey('Content-Type') || receivedHeader.get('Content-Type').toLowerCase() != 'application/json')
            {
                system.debug('Error: Invalid Content-Type header');
                response.statusCode = 400;
                obj = new AC_Response.cls_res();
                clserr = new AC_Response.cls_errors();
                claserr = new list<AC_Response.cls_errors>();
                obj.success = false;
                clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
                clserr.message = 'Error: Invalid Content-Type header';
                claserr.add(clserr);
                obj.errors =claserr;
                clslst.add(obj);
                response.responseBody =  Blob.valueof(json.serialize(clslst,false));
            }
        } // End of Try
        catch(Exception ee)
        {
            system.debug('Error '+ee.getMessage());
            response.statusCode = 400;
            obj = new AC_Response.cls_res();
            clserr = new AC_Response.cls_errors();
            claserr = new list<AC_Response.cls_errors>();
            obj.success = false;
            clserr.statusCode = 'EXCEPTION_HAS_OCCURRED.';
            clserr.message = ee.getMessage();
            claserr.add(clserr);
            obj.errors =claserr;
            clslst.add(obj);
            response.responseBody =  Blob.valueof(json.serialize(clslst,false));
            
        }
    }
}