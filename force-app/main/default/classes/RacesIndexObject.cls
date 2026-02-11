public with sharing class RacesIndexObject {
    public links links{get;set;}
	public list<races> races{get;set;}
	public class self{
		public String href{get;set;}
	}
	public class races{
		public key key{get;set;}
		public String name{get;set;}
		public Integer id{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
}