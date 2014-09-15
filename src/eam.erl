-module(eam).

-export([normalize_qs/2]).

%% TODO: don't do so much typecasting -- extract ? with binary pattern 
%% match
normalize_qs(Qs, Ignore) when is_binary(Qs) ->
    normalize_qs(binary_to_list(Qs), Ignore);
normalize_qs(Qs, Ignore) ->
    Ignore2 = lists:map(fun(Elem) ->
			       case Elem of
				   _ when is_list(Elem) ->
				       list_to_binary(Elem);
				   _ ->
				       Elem
			       end
		       end, Ignore),
    Qs2 = case Qs of
		 [$?|Rest] -> Rest;
		 _ -> Qs
	     end,
    Params = cow_qs:parse_qs(list_to_binary(Qs2)),
    Params2 = lists:filtermap(fun({Key, _Val}) ->
				      case lists:member(Key, Ignore2) of
					  true -> false;
					  false -> true
				      end
			      end, Params),
    Params3 = [binary_to_list(<<X/binary, $=, Y/binary>>) || {X, Y} <- Params2],
    string:join(lists:sort(Params3), "&").
