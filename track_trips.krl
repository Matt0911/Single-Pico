ruleset track_trips {
  meta {
    name "Track Trips"
    description <<
Part 1 Track Trips
>>
    author "Matt Manhardt"
    logging on
    sharing on
    provides process_trip
  }

  rule process_trip {
    select when echo message
    pre{
      mileage = event:attr("mileage");
    }
    {
      send_directive("trip") with
        trip_length = "#{mileage}";
    }
  }
}