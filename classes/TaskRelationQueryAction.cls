public class TaskRelationQueryAction {

    @InvocableMethod(label='Get Task Relations' description='Takes each task and returns a list of contacts with TaskRelation records.')
    public static List<String> buildTaskRelations(List<Id> taskIds) {
        List<String> contactIdStrings  = new List<String>();
        Map<Id, List<Id>> contactIdsByTaskId = getTaskRelationContactsByTaskIdForTasks(new Set<Id>(taskIds));
        for (Id taskId : taskIds) {
            if (contactIdsByTaskId.containsKey(taskId)) {
                contactIdStrings.add(String.join(contactIdsByTaskId.get(taskId), ','));
            } else {
                contactIdStrings.add('');
            }
        }
        return contactIdStrings;
    }

    private static Map<Id, List<Id>> getTaskRelationContactsByTaskIdForTasks(Set<Id> taskIds) {
        Map<Id, List<Id>> contactIdsByTaskId = new Map<Id, List<Id>>();
        List<TaskRelation> taskRelations = queryTaskRelations(taskIds);
        for (TaskRelation taskRelationRecord : taskRelations) {
            if (taskRelationRecord.RelationId.getSObjectType().getDescribe().getName() != 'Contact') {
                continue;
            }

            if (!contactIdsByTaskId.containsKey(taskRelationRecord.TaskId)) {
                contactIdsByTaskId.put(taskRelationRecord.TaskId, new List<Id>());
            }

            contactIdsByTaskId.get(taskRelationRecord.TaskId).add(taskRelationRecord.RelationId);
        }
        return contactIdsByTaskId;
    }

    private static List<TaskRelation> queryTaskRelations(Set<Id> taskIds) {
        return [SELECT Id, RelationId, TaskId FROM TaskRelation WHERE TaskId IN :taskIds AND IsWhat = false];
    }
}