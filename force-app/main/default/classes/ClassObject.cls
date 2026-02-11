public with sharing class ClassObject {
    public list<specializations> specializations{get;set;}
    public power_type power_type{get;set;}
    public media media{get;set;}
    public gender_name gender_name{get;set;}
    public pvp_talent_slots pvp_talent_slots{get;set;}
    public String name{get;set;}
    public list<playable_races> playable_races{get;set;}
    public Integer id{get;set;}
    public list<additional_power_types> additional_power_types{get;set;}
    public links links{get;set;}

    public class specializations{
        public Integer id{get;set;}
        public String name{get;set;}
        public key key{get;set;}
    }
    public class self{
        public String href{get;set;}
    }
    public class pvp_talent_slots{
        public String href{get;set;}
    }
    public class power_type{
        public String name{get;set;}
        public Integer id{get;set;}
        public key key{get;set;}
    }
    public class playable_races{
        public key key{get;set;}
        public Integer id{get;set;}
        public String name{get;set;}
    }
    public class media{
        public key key{get;set;}
        public Integer id{get;set;}
    }
    public class key{
        public String href{get;set;}
    }
    public class gender_name{
        public String female{get;set;}
        public String male{get;set;}
    }
    public class additional_power_types{
        public key key{get;set;}
        public String name{get;set;}
        public Integer id{get;set;}
    }
    public class links{
        public self self{get;set;}
    }
}