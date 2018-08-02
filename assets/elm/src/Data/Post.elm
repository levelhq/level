module Data.Post
    exposing
        ( Post
        , Record
        , fragment
        , decoder
        , decoderWithReplies
        , getId
        , getCachedData
        , groupsInclude
        )

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline as Pipeline
import Connection exposing (Connection)
import Data.Group as Group exposing (Group)
import Data.Reply as Reply exposing (Reply)
import Data.SpaceUser as SpaceUser exposing (SpaceUser)
import GraphQL exposing (Fragment)
import Util exposing (dateDecoder, (=>))


-- TYPES


type Post
    = Post Record


type alias Record =
    { id : String
    , body : String
    , bodyHtml : String
    , author : SpaceUser
    , groups : List Group
    , postedAt : Date
    }


fragment : Fragment
fragment =
    let
        body =
            """
            fragment PostFields on Post {
              id
              body
              bodyHtml
              postedAt
              subscriptionState
              author {
                ...SpaceUserFields
              }
              groups {
                ...GroupFields
              }
            }
            """
    in
        GraphQL.fragment body
            [ SpaceUser.fragment
            , Group.fragment
            ]



-- DECODERS


decoder : Decoder Post
decoder =
    Decode.map Post <|
        (Pipeline.decode Record
            |> Pipeline.required "id" string
            |> Pipeline.required "body" string
            |> Pipeline.required "bodyHtml" string
            |> Pipeline.required "author" SpaceUser.decoder
            |> Pipeline.required "groups" (list Group.decoder)
            |> Pipeline.required "postedAt" dateDecoder
        )


decoderWithReplies : Decoder ( Post, Connection Reply )
decoderWithReplies =
    Decode.map2 (=>) decoder (Connection.decoder Reply.decoder)



-- CRUD


getId : Post -> String
getId (Post { id }) =
    id


getCachedData : Post -> Record
getCachedData (Post data) =
    data


groupsInclude : Group -> Post -> Bool
groupsInclude group (Post data) =
    List.filter (\g -> (Group.getId g) == (Group.getId group)) data.groups
        |> List.isEmpty
        |> not
