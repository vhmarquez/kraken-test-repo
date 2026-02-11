public with sharing class RealmIndexObject {
    public list<realms> realms{get;set;}
	public links links{get;set;}
	public class self{
		public String href{get;set;}
	}
	public class realms{
		public key key{get;set;}
		public String name{get;set;}
		public Integer id{get;set;}
		public String slug{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
}