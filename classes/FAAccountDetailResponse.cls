public class FAAccountDetailResponse  implements Comparable {

    public Integer accountId;
    public String accountNumber;
    public String accountName;
    public String accountTitle;
    public String accountType;
    public String sponsor;
    public String program;
    public String manager;
    public String modelName;
    public String modelDescription;
    public String inceptionValue;
    public Long inceptionDate;
    public Long terminationDate;
    public String terminationValue;
    public Long firstTradeDate;
    public String firstTradeValue;
    public String lifeCycleStep;
    public String faName;
    public String faEmail;

    
    public static List<FAAccountDetailResponse> parse(String json) {
        //return (FAAccountDetailResponse) System.JSON.deserialize(json, FAAccountDetailResponse.class);
        return (List<FAAccountDetailResponse>) System.JSON.deserialize(json, List<FAAccountDetailResponse>.Class);
    }
    
    /**
        * The comparator method used in sorting
        *
        * @param obj The object to compare to
        * @return the integer value of the comparison between the objects
        */
        public Integer compareTo(Object obj) {
            FAAccountDetailResponse response = (FAAccountDetailResponse)(obj);

            if (this.accountName > response.accountName) {      return 1;}

            if (this.accountName == response.accountName) {  return 0; }

            return -1;
        }
}