public with sharing class CharacterProfileSummaryObject {
    public Decimal last_login_timestamp{get;set;}
    public Integer equipped_item_level{get;set;}
    public specializations specializations{get;set;}
    public Integer average_item_level{get;set;}
    public statistics statistics{get;set;}
    public media media{get;set;}
    public mythic_keystone_profile mythic_keystone_profile{get;set;}
    public encounters encounters{get;set;}
    public guild guild{get;set;}
    public Integer level{get;set;}
    public titles titles{get;set;}
    public achievements achievements{get;set;}
    public pvp_summary pvp_summary{get;set;}
    public Integer achievement_points{get;set;}
    public equipment equipment{get;set;}
    public Integer experience{get;set;}
    public appearance appearance{get;set;}
    public realm realm{get;set;}
    public collections collections{get;set;}
    public active_spec active_spec{get;set;}
    public active_title active_title{get;set;}
    public character_class character_class{get;set;}
    public reputations reputations{get;set;}
    public race race{get;set;}
    public quests quests{get;set;}
    public faction faction{get;set;}
    public achievements_statistics achievements_statistics{get;set;}
    public gender gender{get;set;}
    public professions professions{get;set;}
    public String name{get;set;}
    public covenant_progress covenant_progress{get;set;}
    public Integer id{get;set;}
    public String name_search{get;set;}
    public links links{get;set;}
	public class titles{
		public String href{get;set;}
	}
	public class statistics{
		public String href{get;set;}
	}
	public class specializations{
		public String href{get;set;}
	}
	public class soulbinds{
		public String href{get;set;}
	}
	public class self{
		public String href{get;set;}
	}
	public class reputations{
		public String href{get;set;}
	}
	public class realm{
		public Integer id{get;set;}
		public String slug{get;set;}
		public key key{get;set;}
		public name name{get;set;}
	}
	public class race{
		public Integer id{get;set;}
		public name name{get;set;}
		public key key{get;set;}
	}
	public class quests{
		public String href{get;set;}
	}
	public class pvp_summary{
		public String href{get;set;}
	}
	public class professions{
		public String href{get;set;}
	}
	public class name{
		public String es_ES{get;set;}
		public String de_DE{get;set;}
		public String en_GB{get;set;}
		public String pt_BR{get;set;}
		public String fr_FR{get;set;}
		public String es_MX{get;set;}
		public String it_IT{get;set;}
		public String en_US{get;set;}
		public String ru_RU{get;set;}
		public String ko_KR{get;set;}
		public String zh_TW{get;set;}
		public String zh_CN{get;set;}
	}
	public class mythic_keystone_profile{
		public String href{get;set;}
	}
	public class media{
		public String href{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
	public class guild{
		public faction faction{get;set;}
		public String name{get;set;}
		public key key{get;set;}
		public Integer id{get;set;}
		public realm realm{get;set;}
	}
	public class gender{
		public name name{get;set;}
		public String type{get;set;}
	}
	public class faction{
		public name name{get;set;}
		public String type{get;set;}
	}
	public class equipment{
		public String href{get;set;}
	}
	public class encounters{
		public String href{get;set;}
	}
	public class display_string{
		public String de_DE{get;set;}
		public String en_GB{get;set;}
		public String pt_BR{get;set;}
		public String es_ES{get;set;}
		public String es_MX{get;set;}
		public String fr_FR{get;set;}
		public String en_US{get;set;}
		public String it_IT{get;set;}
		public String zh_TW{get;set;}
		public String zh_CN{get;set;}
		public String ko_KR{get;set;}
		public String ru_RU{get;set;}
	}
	public class covenant_progress{
		public chosen_covenant chosen_covenant{get;set;}
		public Integer renown_level{get;set;}
		public soulbinds soulbinds{get;set;}
	}
	public class collections{
		public String href{get;set;}
	}
	public class chosen_covenant{
		public key key{get;set;}
		public Integer id{get;set;}
		public name name{get;set;}
	}
	public class character_class{
		public Integer id{get;set;}
		public name name{get;set;}
		public key key{get;set;}
	}
	public class appearance{
		public String href{get;set;}
	}
	public class active_title{
		public Integer id{get;set;}
		public key key{get;set;}
		public name name{get;set;}
		public display_string display_string{get;set;}
	}
	public class active_spec{
		public Integer id{get;set;}
		public name name{get;set;}
		public key key{get;set;}
	}
	public class achievements_statistics{
		public String href{get;set;}
	}
	public class achievements{
		public String href{get;set;}
	}
	public class links{
		public self self{get;set;}
	}
}