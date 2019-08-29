public without sharing class BuildTaskRelations {

    @InvocableMethod(label='Build Task Relations' description='Takes a semi-colon list of contacts with the task Id being the first id and associates them to that task.')
    public static void buildTaskRelations(List<String> taskAndContactIds) {
        Map<Id, List<Id>> contactIdsByTaskId = getContactIdsByTaskId(taskAndContactIds);
        Map<Id, Map<Id, TaskRelation>> taskRelationsByContactIdByTaskId = getTaskRelationsByContactIdByTaskIdForTasks(contactIdsByTaskId.keySet());
        handleTaskRelationUpdates(contactIdsByTaskId, taskRelationsByContactIdByTaskId);
    }

    private static Map<Id, List<Id>> getContactIdsByTaskId(List<String> taskAndContactIds) {
        Map<Id, List<Id>> contactIdsByTaskId = new Map<Id, List<Id>>();
        for (String taskAndContactId : taskAndContactIds) {
            List<String> ids = taskAndContactIds[0].split(',');
            Id taskId = ids.remove(0);
            contactIdsByTaskId.put(taskId, ids);
        }
        return contactIdsByTaskId;
    }

    private static Map<Id, Map<Id, TaskRelation>> getTaskRelationsByContactIdByTaskIdForTasks(Set<Id> taskIds) {
        Map<Id, Map<Id, TaskRelation>> taskRelationsByContactIdByTaskId = new Map<Id, Map<Id, TaskRelation>>();
        List<TaskRelation> taskRelations = queryTaskRelations(taskIds);
        for (TaskRelation taskRelationRecord : taskRelations) {
            if (taskRelationRecord.RelationId.getSObjectType().getDescribe().getName() != 'Contact') {
                continue;
            }

            if (!taskRelationsByContactIdByTaskId.containsKey(taskRelationRecord.TaskId)) {
                taskRelationsByContactIdByTaskId.put(taskRelationRecord.TaskId, new Map<Id, TaskRelation>());
            }

            taskRelationsByContactIdByTaskId.get(taskRelationRecord.TaskId).put(taskRelationRecord.RelationId, taskRelationRecord);
        }
        return taskRelationsByContactIdByTaskId;
    }

    private static List<TaskRelation> queryTaskRelations(Set<Id> taskIds) {
        return [SELECT Id, RelationId, TaskId FROM TaskRelation WHERE TaskId IN :taskIds AND IsWhat = false];
    }

    private static void handleTaskRelationUpdates(Map<Id, List<Id>> contactIdsByTaskId, Map<Id, Map<Id, TaskRelation>> taskRelationsByContactIdByTaskId) {
        List<TaskRelation> taskRelationsToCreate = new List<TaskRelation>();
        List<TaskRelation> taskRelationsToDelete = new List<TaskRelation>();
        for (Id taskId : contactIdsByTaskId.keySet()) {
            if (taskRelationsByContactIdByTaskId.containsKey(taskId)) {
                Map<String, List<TaskRelation>> taskRelationsFromExistingRelationRecord = getTaskRelationsForExistingRecord(contactIdsByTaskId.get(taskId), taskRelationsByContactIdByTaskId.get(taskId));
                taskRelationsToDelete.addAll(taskRelationsFromExistingRelationRecord.get('ToDelete'));
                taskRelationsToCreate.addAll(taskRelationsFromExistingRelationRecord.get('ToCreate'));
            } else {
                taskRelationsToCreate.addAll(createAllTaskRelations(taskId, contactIdsByTaskId.get(taskId)));
            }
        }

        insert taskRelationsToCreate;
        delete taskRelationsToDelete;
    }

    private static Map<String, List<TaskRelation>> getTaskRelationsForExistingRecord(List<Id> contactIdsToHaveRelationsFor, Map<Id, TaskRelation> existingTaskRelationsByContactId) {
        Map<String, List<TaskRelation>> taskRelationsToDoDmlWith = new Map<String, List<TaskRelation>> { 'ToDelete' => new List<TaskRelation>(), 'ToCreate' => new List<TaskRelation>() };
        return taskRelationsToDoDmlWith;
    }

    private static List<TaskRelation> createAllTaskRelations(Id taskId, List<Id> contactIds) {
        List<TaskRelation> taskRelationsToCreate = new List<TaskRelation>();
        for (Id contactId : contactIds) {
            TaskRelation taskRelationToCreate = new TaskRelation();
            taskRelationToCreate.TaskId = taskId;
            taskRelationToCreate.RelationId = contactId;
            taskRelationsToCreate.add(taskRelationToCreate);
        }
        return taskRelationsToCreate;
    }
}