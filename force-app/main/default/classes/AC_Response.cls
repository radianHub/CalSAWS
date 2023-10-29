// Response class 
public class AC_Response{
	public cls_res cls_resref;
	public class cls_res {
		public boolean success;
        public string recordId;
		public cls_errors[] errors;
	}
	public class cls_errors {
		public String statusCode;	
		public String message;	
		public list<string> fields;
	}
	
	public static AC_Response parse(String json){
		return (AC_Response) System.JSON.deserialize(json, AC_Response.class);
	}
}