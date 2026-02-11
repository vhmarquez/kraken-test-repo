public with sharing class CharacterMediaSummaryObject {
    public character character{get;set;}
	public list<assets> assets{get;set;}
	public links links{get;set;}
	public class self{
		public String href{get;set;}
	}
	public class realm{
		public key key{get;set;}
		public String name{get;set;}
		public Integer id{get;set;}
		public String slug{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
	public class character{
		public Integer id{get;set;}
		public realm realm{get;set;}
		public String name{get;set;}
		public key key{get;set;}
	}
	public class assets{
		public String key{get;set;}
		public String value{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
}