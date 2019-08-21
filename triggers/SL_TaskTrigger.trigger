trigger SL_TaskTrigger on Task (after insert, after update) {
  
    List<Task> taskList = trigger.new;
    Map<Id, Task> taskListold = trigger.oldMap;
    Set<Id> setIds = new Set<Id>();
    for (Integer i = 0; i < taskList.size(); i++) {
        if(Trigger.old != null && taskList[i].WhatId  != taskListold.get( taskList[i].Id ).WhatId){
            if((''+taskList[i].WhatId).substring(0,3) == '001'){
                setIds.add(taskList[i].WhatId);
            }
            if((''+taskListold.get( taskList[i].Id ).WhatId).substring(0,3) == '001'){
                setIds.add(taskListold.get( taskList[i].Id ).WhatId);
            }
        }
        if((''+taskList[i].WhatId).substring(0,3) == '001'){
            setIds.add(taskList[i].WhatId);
        }
        
    }
    
    List<Task> taskListnew = [SELECT id, WhatId FROM Task WHERE WhatId IN : setIds LIMIT 10000];
            
    Map<Id, Integer> mapOfCount = new Map<Id, Integer>();
    
    for (Integer i = 0; i < taskListnew.size(); i++) {
        if(mapOfCount.get(taskListnew[i].WhatId) == null){
            mapOfCount.put(taskListnew[i].WhatID, 1);
        }else{
            Integer countTasks = mapOfCount.get(taskListnew[i].WhatID);
            countTasks++;
            
            mapOfCount.put(taskListnew[i].WhatID, countTasks);
        }
    }

    List<Account> lstAcc = new List<Account>();
    
    for(Id accId : mapOfCount.keySet()){
        lstAcc.add(new Account(id = accId, NumberOfOpenTasks__c = mapOfCount.get(accId)));
    }
    
    update lstAcc;

    switch on Trigger.operationType {
        when AFTER_INSERT {
            List<Task> setTasks= new List<Task>();
            for (Integer i = 0; i < taskList.size(); i++) {
                if((''+taskList[i].WhatId).substring(0,3) == 'a18'){
                    setTasks.add(taskList[i]);
                }           
            }

            List<Task> newLst = new List<Task>();
            for (Integer i = 0; i < setTasks.size(); i++) {
                newLst.add( new Task(id = setTasks[i].Id,  Action_Plan_Task__c = true));
            }

            if(newLst.size() > 0){
                update newLst;
            }
        }
        when AFTER_UPDATE {
            List<Id> lstIds = new List<Id>();
            for (Integer i = 0; i < taskList.size(); i++) {
                if(Trigger.old != null){
                    if( taskList[i].Status == 'Completed' &&
                        taskListold.get( taskList[i].Id ).Status != 'Completed' &&
                        taskList[i].Action_Plan_Task__c == true) {
                        lstIds.add(taskList[i].Id);
                    }
                }
            }
            
            List <Task> lstTasks = [SELECT id,ActivityDate FROM Task WHERE id IN : lstIds ];
            for (Integer i = 0; i < lstTasks.size(); i++) {
                lstTasks[i].ActivityDate =  Date.today();
            }
            update lstTasks;
        }

    }
    
}