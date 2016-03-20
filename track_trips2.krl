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
  }

  global {
    long_trip = 100;
  }

  rule process_trip {
    select when car new_trip
    fired {
      log ("LOG raise trip_processed event");
      raise explicit event 'trip_processed'
        with attributes = event:attrs()
        and time = time:now();
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("attributes","mileage");
      time = event:attr("time");
    }
    fired {
      log ("LOG Trip was processed: " + mileage + "," + time);
      raise explicit event 'found_long_trip'
        if (mileage > long_trip);
    }
  }
}