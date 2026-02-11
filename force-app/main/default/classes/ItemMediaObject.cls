public with sharing class ItemMediaObject {
    public list<assets> assets{get;set;}
    public Integer id{get;set;}
    public links links{get;set;}
	public class self{
		public String href{get;set;}
	}
	public class assets{
		public String value{get;set;}
		public String key{get;set;}
		public Integer file_data_id{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
}