module Model where

import List

type alias Post =
  { id : String
  , title : String
  , body : String
  }

posts : List {title:String,body:String,id:String}
posts =
  [ { title = "Blah Doo Dah"
    , body = "This is such an awesome post"
    , id = "1"
    }
  , { title = "Doo Dah Dee"
    , body = "This one isn't as good."
    , id = "2"
    }
  ]

findPost id =
  List.foldl (\pp p -> if p.id == id then p else pp)
    (List.head posts)
    (List.tail posts)
