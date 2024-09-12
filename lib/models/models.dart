class UserModel {
  final String fullName;
  final String email;

  final String nickname; // Doc, Pharmacist, e.t.c
  final String title;
  final String uid;

  UserModel({
    required this.fullName,
    required this.email,
    required this.nickname,
    required this.title,
    required this.uid,
  });

// toJson

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "nickname": nickname,
        "title": title,
        "uid": uid,
      };
}

class eventmodel {
  final String title;
  final String description;
  final String community;
  final DateTime eventdate;
  final String reg_link;
  final String resorce_link;
  final String cover_image;
  final String Uid;
  final List<String> other_images;

  eventmodel({
    required this.title,
    required this.description,
    required this.community,
    required this.cover_image,
    required this.eventdate,
    required this.reg_link,
    required this.resorce_link,
    required this.Uid,
    required this.other_images,
  });

  //to jyson

  Map<String, dynamic> toJson() => {
        "Title": title,
        "Description": description,
        "Community": community,
        "EventDate": eventdate,
        "Regestration": reg_link,
        "Resorces": resorce_link,
        "Uid": Uid,
      };
}

class announcementModel {
  final String title;
  final String description;
  final String community;
  final String ImagePath;
  final String AnnouncentId;
  final String UserId;
  final DateTime announceTime;

  announcementModel({
    required this.ImagePath,
    required this.community,
    required this.description,
    required this.title,
    required this.AnnouncentId,
    required this.UserId,
    required this.announceTime,
  });
  //to json

  Map<String, dynamic> tojson() => {
        "Community": community,
        "Description": description,
        "Title": title,
        "AnnouncementId": AnnouncentId,
        "UserId": UserId,
        "AnnounceTime": announceTime,
      };
}

class postmodel {
  final String blog;
  final List<String> images;
  final String postId;
  final String UserId;
  final DateTime posttime;
  postmodel({
    required this.blog,
    required this.images,
    required this.postId,
    required this.UserId,
    required this.posttime,
  });

  Map<String, dynamic> tojson() => {
        "UserId": UserId,
        "BlogPost": blog,
        "PostId": postId,
        "PostTime": posttime,
      };
}

class communityModel {
  final String name;
  final String Lead;
  final List<String> eventsId;
  final String Email;
  final Map<String, String> numbers;
  final String uid;
  final bool visibility;
  final List<String> category ;
  communityModel({
    required this.Lead,
    required this.eventsId,
    required this.name,
    required this.Email,
    required this.numbers,
    required this.uid,
    required this.visibility,
    required this.category
  });

  //to json
  Map<String, dynamic> tojson() => {
        "Lead": Lead,
        "Name": name,
        "events": eventsId,
        "Email": Email,
        "Numbers": numbers,
        "Uid": uid,
        "Visibility": visibility,
        "Category":category
        
      };
}

class rsvpmodel {
  final List<String> rsvps;
  
  rsvpmodel({
    required this.rsvps,
  }) ;
  Map<String, dynamic> tojson() => {
        "Events": rsvps,
      };
}
class joincomModel{
  
  List<String> comm ;
  joincomModel({
    
    required this.comm,
  });
  
  Map<String,List> tojson() =>{
    "Communities":comm,
  };
}
