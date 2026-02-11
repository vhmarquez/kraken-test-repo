public with sharing class ClassesIndexObject {
    public list<classes> classes{get;set;}
	public links links{get;set;}
	public class self{
		public String href{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
	public class classes{
		public key key{get;set;}
		public String name{get;set;}
		public Integer id{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
}