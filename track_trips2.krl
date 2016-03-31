ruleset track_trips2 {
  meta {
    name "Track Trips 2"
    description <<
Part 2 Track Trips
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides process_trip
    use module  b507199x5 alias wrangler_api
    use module  b507199x5 alias wranglerOS
  }

  global {
    long_trip = 100;
  }

  rule process_trip {
    select when car new_trip
    fired {
      log ("LOG raise trip_processed event");
      raise explicit event 'trip_processed'
        with mileage = event:attr("mileage")
        and time = time:now();
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage");
      time = event:attr("time");
    }
    fired {
      log ("LOG Trip was processed: " + mileage + "," + time);
      raise explicit event 'found_long_trip'
        with mileage = event:attr("mileage")
        and time = event:attr("time")
        if (mileage > long_trip);
    }
  }

  rule delete_vehicle {
    select when explicit delete_vehicle
    pre {
      name = event:attr("name");
      results = wranglerOS:name();
      picoName = results{"picoName"};

      subs = wranglerOS:subscriptions();
      //log ("subscriptions: " + subs);
      subscriptions = subs{"subscriptions"};
      subscribed = subscriptions{"subscribed"};
      sub = subscribed[0];
      subKeys = sub.keys();
      info = sub{[subKeys[0]]};
      //subname = info{["subscription_name"]};
      //log ("attr: " + name + ", pico: " + picoName + ", sub: " + subname);
    }
    fired {
      log("HASH PLEASE: " + info);
      raise wrangler event 'subscription_cancellation'
        with channel_name = subname
        if (name == picoName);
      log("DELETION ATTRIBUTES attr: " + name + ", pico: " + picoName + ", sub: " + subname);
      //raise wrangler event 'child_deletion'
        //with deletionTarget = meta:eci()
        //if (name == picoName);
    }

  }

  rule childToParent {
    select when wrangler init_events
    pre {
       // find parant 
       // place  "use module  b507199x5 alias wrangler_api" in meta block!!
       parent_results = wrangler_api:parent();
       parent = parent_results{'parent'};
       parent_eci = parent[0]; // eci is the first element in tuple 
       attrs = {}.put(["name"],"Fleet")
                      .put(["name_space"],"Tutorial_Subscriptions")
                      .put(["my_role"],"vehicle")
                      .put(["your_role"],"fleet")
                      .put(["target_eci"],parent_eci.klog("target Eci: "))
                      .put(["channel_type"],"Pico_Tutorial")
                      .put(["attrs"],"success")
                      ;
    }
    {
     noop();
    }
    always {
      raise wrangler event "subscription"
      attributes attrs;
    }
  }
}