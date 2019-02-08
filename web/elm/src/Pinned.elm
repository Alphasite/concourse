module Pinned exposing
    ( CommentState
    , ResourcePinState(..)
    , VersionPinState(..)
    , finishPinning
    , pinState
    , quitUnpinning
    , stable
    , startPinningTo
    , startUnpinning
    )


type alias CommentState =
    { comment : String
    , pristineComment : String
    }


type ResourcePinState version id comment
    = NotPinned
    | PinningTo id
    | PinnedDynamicallyTo comment version
    | UnpinningFrom comment version
    | PinnedStaticallyTo version


type VersionPinState
    = Enabled
    | PinnedDynamically
    | PinnedStatically { showTooltip : Bool }
    | Disabled
    | InTransition


startPinningTo :
    id
    -> ResourcePinState version id CommentState
    -> ResourcePinState version id CommentState
startPinningTo destination resourcePinState =
    case resourcePinState of
        NotPinned ->
            PinningTo destination

        x ->
            x


finishPinning :
    (id -> Maybe version)
    -> ResourcePinState version id CommentState
    -> ResourcePinState version id CommentState
finishPinning lookup resourcePinState =
    case resourcePinState of
        PinningTo b ->
            lookup b
                |> Maybe.map
                    (PinnedDynamicallyTo { comment = "", pristineComment = "" })
                |> Maybe.withDefault NotPinned

        x ->
            x


startUnpinning :
    ResourcePinState version id CommentState
    -> ResourcePinState version id CommentState
startUnpinning resourcePinState =
    case resourcePinState of
        PinnedDynamicallyTo c v ->
            UnpinningFrom c v

        x ->
            x


quitUnpinning :
    ResourcePinState version id CommentState
    -> ResourcePinState version id CommentState
quitUnpinning resourcePinState =
    case resourcePinState of
        UnpinningFrom c v ->
            PinnedDynamicallyTo c v

        x ->
            x


stable : ResourcePinState version id CommentState -> Maybe version
stable version =
    case version of
        PinnedStaticallyTo v ->
            Just v

        PinnedDynamicallyTo _ v ->
            Just v

        _ ->
            Nothing


pinState :
    version
    -> id
    -> ResourcePinState version id CommentState
    -> VersionPinState
pinState version id resourcePinState =
    case resourcePinState of
        PinnedStaticallyTo v ->
            if v == version then
                PinnedStatically { showTooltip = False }

            else
                Disabled

        NotPinned ->
            Enabled

        PinningTo destination ->
            if destination == id then
                InTransition

            else
                Disabled

        PinnedDynamicallyTo _ v ->
            if v == version then
                PinnedDynamically

            else
                Disabled

        UnpinningFrom _ v ->
            if v == version then
                InTransition

            else
                Disabled
