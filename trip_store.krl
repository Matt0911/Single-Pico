ruleset track_store {
  meta {
    name "Trip Store"
    description <<
Part 3 Store Trips
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides collect_trips
    provides collect_long_trips
    provides clear_trips
  }

  global {
    
  }

  rule colect_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage");
    }
    fired {
      log ("LOG Collect trip with: " + mileage);
      set ent:trips init if not ent:trips{["_0"]};
      set ent:trips{time:now()} mileage;
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre{
      mileage = event:attr("mileage");
    }
    fired {
      log ("LOG Collect Long Trip: " + mileage);
      set ent:longTrips init if not ent:longTrips{["_0"]};
      set ent:longTrips{time:now()} mileage;
    }
  }

  rule clear_trips {
    select when car trip_reset
    fired {
      log("LOG Clear all trips");
      clear ent:trips;
      clear ent:longTrips;
    }
  }
}