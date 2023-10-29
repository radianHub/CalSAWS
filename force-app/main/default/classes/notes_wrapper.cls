//Wrapper class for notes
public class notes_wrapper{
    public cls_records[] records;
    public class cls_records {
        public String ServiceActivityName; 
        public datetime CC3DateTime;//2017-01-04T18:50:10.000Z
        public string Name; 
        public string Body;
        public string CC3UserName;
        
    }
    public static notes_wrapper parse(String json){
        return (notes_wrapper) System.JSON.deserialize(json, notes_wrapper.class);
    }
}