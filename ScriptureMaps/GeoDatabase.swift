//
//  GeoDatabase.swift
//  Map Scriptures
//
//  Created by Steve Liddle on 11/5/14.
//  Copyright (c) 2014 IS 543. All rights reserved.
//

import Foundation
import SQLite

// MARK: - SQLite schema expressions

// Columns in the book table
let gBookId = Expression<Int>("ID")
let gBookAbbr = Expression<String>("Abbr")
let gBookCiteAbbr = Expression<String>("CiteAbbr")
let gBookCiteFull = Expression<String>("CiteFull")
let gBookFullName = Expression<String>("FullName")
let gBookNumChapters = Expression<Int?>("NumChapters")
let gBookParentBookId = Expression<Int?>("ParentBookID")
let gBookWebTitle = Expression<String>("WebTitle")
let gBookTocName = Expression<String>("TOCName")
let gBookSubdiv = Expression<String?>("Subdiv")
let gBookBackName = Expression<String>("BackName")
let gBookGridName = Expression<String>("GridName")
let gBookHeading2 = Expression<String>("Heading2")

// Columns in the geocategory table
let gGeoCategoryId = Expression<Int>("Id")
let gGeoCategoryCategory = Expression<String>("Category")

// Columns in the geocategory table
let gGeoPlaceId = Expression<Int>("Id")
let gGeoPlacePlacename = Expression<String>("Placename")
let gGeoPlaceLatitude = Expression<Double>("Latitude")
let gGeoPlaceLongitude = Expression<Double>("Longitude")
let gGeoPlaceFlag = Expression<String?>("Flag")
let gGeoPlaceViewLatitude = Expression<Double?>("ViewLatitude")
let gGeoPlaceViewLongitude = Expression<Double?>("ViewLongitude")
let gGeoPlaceViewTilt = Expression<Double?>("ViewTilt")
let gGeoPlaceViewRoll = Expression<Double?>("ViewRoll")
let gGeoPlaceViewAltitude = Expression<Double?>("ViewAltitude")
let gGeoPlaceViewHeading = Expression<Double?>("ViewHeading")
let gGeoPlaceCategory = Expression<Int>("Category")

// Columns in the geocategory table
let gGeoTagGeoPlaceId = Expression<Int>("GeoplaceId")
let gGeoTagScriptureId = Expression<Int>("ScriptureId")
let gGeoTagStartOffset = Expression<Int>("StartOffset")
let gGeoTagEndOffset = Expression<Int>("EndOffset")

// Columns in the scripture table
let gScriptureId = Expression<Int>("ID")
let gScriptureBookId = Expression<Int>("BookID")
let gScriptureChapter = Expression<Int>("Chapter")
let gScriptureVerse = Expression<Int>("Verse")
let gScriptureFlag = Expression<String>("Flag")
let gScriptureText = Expression<String>("Text")

// MARK: - GeoDatabase class

class GeoDatabase {
    // MARK: - Constants

    class var DB_FILENAME: String { return "geo.21" }
    class var DB_EXTENSION: String { return "sqlite" }

    // MARK: - Properties

    var db = Database(NSBundle.mainBundle().pathForResource(DB_FILENAME, ofType: DB_EXTENSION))

    // MARK: - Singleton

    // See http://bit.ly/1tdRybj for a discussion of this singleton pattern.
    class var sharedGeoDatabase : GeoDatabase {
        struct Singleton {
            static let instance = GeoDatabase()
        }

        return Singleton.instance
    }

    private init() {
        // This guarantees that code outside this file can't instantiate a GeoDatabase.
        // So others must use the sharedGeoDatabase singleton.
    }

    // MARK: - Helpers

    //
    // Return a Book object for the given book ID.
    //
    func bookForId(bookId: Int) -> Book {
        let bookRecord = db["book"].filter(gBookId == bookId)

        return Book.fromRow(bookRecord.first!)
    }

    //
    // Return array of Book objects for the given volume ID (i.e. parent book ID).
    //
    func booksForParentId(parentBookId: Int) -> [Book] {
        var books = [Book]()

        for bookRecord in db["book"].filter(gBookParentBookId == parentBookId).order(gBookId) {
            books.append(Book.fromRow(bookRecord))
        }

        return books
    }

    //
    // Return a query that will generate the join of geotags and geoplaces for
    // a given scripture ID.
    //
    func geoTagsForScriptureId(scriptureId: Int) -> Query {
        return db["geotag"].join(db["geoplace"],
            on: gGeoTagGeoPlaceId == gGeoPlaceId &&
                gGeoTagScriptureId == scriptureId).order(gGeoTagEndOffset.desc)
    }

    //
    // Return a query that will generate all verses for a given book ID and chapter.
    //
    func versesForScriptureBookId(bookId: Int, _ chapter: Int) -> Query {
        return db["scripture"].filter(gScriptureBookId == bookId &&
                                      gScriptureChapter == chapter).order(gScriptureVerse)
    }

    //
    // Return an array of strings listing the titles of all scripture volumes.
    //
    func volumes() -> [String] {
        // NEEDSWORK: replace this with code to read the volume titles from the database
        var volumes = [String]()
        
        for volume in db["book"].filter(gBookParentBookId == nil) {
            volumes.append(volume.get(gBookFullName))
        }
        return volumes
    }
}
