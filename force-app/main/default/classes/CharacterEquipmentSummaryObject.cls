public with sharing class CharacterEquipmentSummaryObject {
    public list<equipped_items> equipped_items{get;set;}
    public character character{get;set;}
    public list<equipped_item_sets> equipped_item_sets{get;set;}
    public links_extra links_extra{get;set;}
	public class type{
		public String name{get;set;}
		public String type{get;set;}
	}
	public class transmog{
		public item item{get;set;}
		public Integer item_modified_appearance_id{get;set;}
		public String display_string{get;set;}
	}
	public class stats{
		public display display{get;set;}
		public Integer value{get;set;}
		public type type{get;set;}
	}
	public class slot{
		public String name{get;set;}
		public String type{get;set;}
	}
	public class set_bonus{
		public item_set item_set{get;set;}
		public list<effects> effects{get;set;}
		public String display_string{get;set;}
		public list<items> items{get;set;}
	}
	public class sell_price{
		public Integer value{get;set;}
		public display_strings display_strings{get;set;}
	}
	public class self{
		public String href{get;set;}
	}
	public class requirements{
		public level level{get;set;}
		public playable_classes playable_classes{get;set;}
	}
	public class realm{
		public Integer id{get;set;}
		public String name{get;set;}
		public String slug{get;set;}
		public key key{get;set;}
	}
	public class quality{
		public String name{get;set;}
		public String type{get;set;}
	}
	public class playable_classes{
		public String display_string{get;set;}
		public list<links> links{get;set;}
	}
	public class name_description{
		public String display_string{get;set;}
		public color color{get;set;}
	}
	public class media{
		public Integer id{get;set;}
		public key key{get;set;}
	}
	public class links{
		public Integer id{get;set;}
		public key key{get;set;}
		public String name{get;set;}
	}
	public class level{
		public Integer value{get;set;}
		public String display_string{get;set;}
	}
	public class key{
		public String href{get;set;}
	}
	public class items{
		public item item{get;set;}
		public Boolean is_equipped{get;set;}
	}
	public class item_subclass{
		public Integer id{get;set;}
		public String name{get;set;}
		public key key{get;set;}
	}
	public class item_set{
		public String name{get;set;}
		public Integer id{get;set;}
		public key key{get;set;}
	}
	public class item_class{
		public Integer id{get;set;}
		public String name{get;set;}
		public key key{get;set;}
	}
	public class item{
		public String name{get;set;}
		public key key{get;set;}
		public Integer id{get;set;}
	}
	public class inventory_type{
		public String name{get;set;}
		public String type{get;set;}
	}
	public class equipped_items{
		public sell_price sell_price{get;set;}
		public binding binding{get;set;}
		public armor armor{get;set;}
		public inventory_type inventory_type{get;set;}
		public list<stats> stats{get;set;}
		public item_subclass item_subclass{get;set;}
		public requirements requirements{get;set;}
		public item_class item_class{get;set;}
		public set_bonus set_bonus{get;set;}
		public media media{get;set;}
		public level level{get;set;}
		public Integer modified_appearance_id{get;set;}
		public transmog transmog{get;set;}
		public String name{get;set;}
		public durability durability{get;set;}
		public quality quality{get;set;}
		public name_description name_description{get;set;}
		public list<String> bonus_list{get;set;}
		public Integer quantity{get;set;}
		public slot slot{get;set;}
		public Integer context{get;set;}
		public item item{get;set;}
	}
	public class equipped_item_sets{
		public item_set item_set{get;set;}
		public list<effects> effects{get;set;}
		public String display_string{get;set;}
		public list<items> items{get;set;}
	}
	public class effects{
		public String display_string{get;set;}
		public Integer required_count{get;set;}
		public Boolean is_active{get;set;}
	}
	public class durability{
		public String display_string{get;set;}
		public Integer value{get;set;}
	}
	public class display_strings{
		public String silver{get;set;}
		public String gold{get;set;}
		public String copper{get;set;}
		public String header{get;set;}
	}
	public class display{
		public String display_string{get;set;}
		public color color{get;set;}
	}
	public class color{
		public Decimal a{get;set;}
		public Integer b{get;set;}
		public Integer r{get;set;}
		public Integer g{get;set;}
	}
	public class character{
		public realm realm{get;set;}
		public String name{get;set;}
		public Integer id{get;set;}
		public key key{get;set;}
	}
	public class binding{
		public String name{get;set;}
		public String type{get;set;}
	}
	public class armor{
		public display display{get;set;}
		public Integer value{get;set;}
	}
	public class links_extra{
		public self self{get;set;}
	}
}