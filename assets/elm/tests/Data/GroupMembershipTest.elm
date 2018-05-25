module Data.GroupMembershipTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (string)
import Data.GroupMembership as GroupMembership exposing (GroupMembershipState(..))
import Test exposing (..)
import Json.Decode as Decode exposing (decodeString)
import TestHelpers exposing (success)


stateDecoder =
    decodeString (Decode.at [ "membership" ] GroupMembership.groupSubscriptionLevelDecoder)


{-| Tests for JSON decoders.
-}
decoders : Test
decoders =
    describe "decoders"
        [ describe "GroupMembership.groupSubscriptionLevelDecoder"
            [ test "decodes subscribed state" <|
                \_ ->
                    let
                        json =
                            """
                              {
                                "membership": {
                                  "state": "SUBSCRIBED"
                                }
                              }
                            """

                        result =
                            stateDecoder json
                    in
                        Expect.equal (Ok Subscribed) result
            , test "decodes not subscribed state" <|
                \_ ->
                    let
                        json =
                            """
                              {
                                "membership": null
                              }
                            """

                        result =
                            stateDecoder json
                    in
                        Expect.equal (Ok NotSubscribed) result
            , test "errors out with invalid states" <|
                \_ ->
                    let
                        json =
                            """
                              {
                                "membership": {
                                  "state": "INVALID"
                                }
                              }
                            """

                        result =
                            stateDecoder json
                    in
                        Expect.equal (Err "I ran into a `fail` decoder at _.membership: Subscription level not valid") result
            ]
        ]