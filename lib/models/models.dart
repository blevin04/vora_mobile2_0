// ignore_for_file: non_constant_identifier_names

class UserModel {
  final String fullName;
  final String email;
  final List<String> membercommunities= List.empty(growable: true);
  final String nickname; // Doc, Pharmacist, e.t.c
  
  final String uid;
  final List<String> attendedevents = List.empty(growable: true);
  UserModel({
    required this.fullName,
    required this.email,
    required this.nickname,
   
    required this.uid,
  });

// toJson

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "nickname": nickname,
        
        "uid": uid,
        "Communities":membercommunities,
        "Events":attendedevents,
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
  final List Likes;
  final Map<String,dynamic> comments;
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
    required this.Likes,
    required this.comments,
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
        "Likes": Likes,
        "Comments": comments,
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
        "Viewed":[]
      };
}

class postmodel {
  final String blog;
  final List<String> images;
  final String postId;
  final String UserId;
  final DateTime posttime;
  final List<String> Likes;
  final String title;
  final Map<String,dynamic> comments_;
  postmodel({
    
    required this.blog,
    required this.images,
    required this.postId,
    required this.UserId,
    required this.posttime,
    required this.Likes,
    required this.title,
    required this.comments_
  });

  Map<String, dynamic> tojson() => {
        "UserId": UserId,
        "BlogPost": blog,
        "PostId": postId,
        "PostTime": posttime,
        "Likes": Likes,
        "Comments":comments_,
        "Title" : title,
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
  final String about;
  communityModel({
    required this.Lead,
    required this.eventsId,
    required this.name,
    required this.Email,
    required this.numbers,
    required this.uid,
    required this.visibility,
    required this.category,
    required this.about,
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
        "Category":category,
        "About":about,
        
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
