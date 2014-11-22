//
//  ScriptureRenderer.swift
//  Map Scriptures
//
//  Created by Steve Liddle on 11/7/14.
//  Copyright (c) 2014 IS 543. All rights reserved.
//

import Foundation
import SQLite

extension String {
    mutating func convertToHtmlEntities() -> String {
        self.replaceAllSubstrings([
            "\u{00b6}" : "&para;",   "\u{2014}" : "&mdash;",  "\u{2013}" : "&ndash;",
            "\u{201c}" : "&ldquo;",  "\u{201d}" : "&rdquo;",  "\u{2018}" : "&lsquo;",
            "\u{2019}" : "&rsquo;",  "\u{2026}" : "&hellip;", "\u{00e9}" : "&eacute;",
            "\u{00e1}" : "&aacute;", "\u{00ed}" : "&iacute;", "\u{00f3}" : "&oacute;",
            "\u{00fa}" : "&uacute;", "\u{00f1}" : "&ntilde;",
        ])

        return self
    }

    mutating func replaceAllSubstrings(replacements: [String : String]) -> String {
        for (target, replacement) in replacements {
            self = self.stringByReplacingOccurrencesOfString(target, withString: replacement,
                options: .CaseInsensitiveSearch, range: nil)
        }

        return self
    }
}

class ScriptureRenderer {
    // MARK: - Constants
    let BASE_URL = "http://scriptures.byu.edu/mapscrip/"
    let FOOTNOTE_VERSE = 1000

    // MARK: - Properties

    var renderLongTitles = true
    var collectedGeocodedPlaces = [GeoPlace]()

    // MARK: - Singleton

    // See http://bit.ly/1tdRybj for a discussion of this singleton pattern.
    class var sharedRenderer : ScriptureRenderer {
        struct Singleton {
            static let instance = ScriptureRenderer()
        }

        return Singleton.instance
    }

    private init() {
        // This guarantees that code outside this file can't instantiate a ScriptureRenderer.
        // So others must use the sharedRenderer singleton.
    }

    // MARK: - Helpers

    func htmlForBookId(bookId: Int, chapter: Int) -> String {
        var book = GeoDatabase.sharedGeoDatabase.bookForId(bookId)
        var title = ""
        var heading1 = ""
        var heading2 = ""

        title = titleForBook(book, chapter)

        heading1 = book.webTitle

        if !isSupplementary(book) {
            heading2 = book.heading2

            if heading2 != "" {
                heading2 = "\(heading2)\(chapter)"
            }
        }

        let stylePath = NSBundle.mainBundle().pathForResource("scripture", ofType: "css")!
        let scriptureStyle = NSString(contentsOfFile: stylePath, encoding: NSUTF8StringEncoding, error: nil)

        var page = "<!doctype html>\n<html><head><title>\(title)</title>\n"

        page += "<style type=\"text/css\">\n\(scriptureStyle)\n</style>\n"
        page += "</head>\n<body>"
        page += "<div class=\"heading1\">\(heading1)</div>"
        page += "<div class=\"heading2\">\(heading2)</div>"
        page += "<div class=\"chapter\">"

        collectedGeocodedPlaces = [GeoPlace]()

        for verse in GeoDatabase.sharedGeoDatabase.versesForScriptureBookId(bookId, chapter) {
            var verseClass = "verse"
            let flag = verse.get(gScriptureFlag)
            let verseNumber = verse.get(gScriptureVerse)
            let verseText = verse.get(gScriptureText)
            let scriptureId = verse.get(gScriptureId)

            if flag == "H" {
                verseClass = "headVerse"
            }

            page += "<a name=\"\(verseNumber)\"><div class=\"\(verseClass)\">"

            if verseNumber > 1 && verseNumber < FOOTNOTE_VERSE {
                page += "<span class=\"verseNumber\">\(verseNumber)</span>"
            }

            page += geocodedTextForVerseText(verseText, scriptureId)
            page += "</div>"
        }

        page += "</div></body></html>"

        return page.convertToHtmlEntities()
    }

    func geocodedTextForVerseText(var verseText: String, _ scriptureId: Int) -> String {
        for tagRecord in GeoDatabase.sharedGeoDatabase.geoTagsForScriptureId(scriptureId) {
            let geoplace = GeoPlace(fromRow: tagRecord)
            let placename = geoplace.placename.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let startIndex: String.Index = advance(verseText.startIndex, tagRecord.get(gGeoTagStartOffset))
            let endIndex: String.Index = advance(verseText.startIndex, tagRecord.get(gGeoTagEndOffset))

            collectedGeocodedPlaces.append(geoplace)
           
            // Insert hyperlink for geotag in this verse at the given offsets
            let encodedPlace = placename.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            verseText = verseText.substringToIndex(startIndex) +
                "<a href=\"\(BASE_URL)\(geoplace.id)\">" +
                        verseText.substringWithRange(Range<String.Index>(start: startIndex, end: endIndex)) +
                        "</a>" + verseText.substringFromIndex(endIndex)
        }

        return verseText
    }

    func isSupplementary(book: Book) -> Bool {
        return book.numChapters == nil && book.parentBookId != nil;
    }

    func titleForBook(book: Book, _ chapter: Int) -> String {
        var title: String = renderLongTitles ? book.citeFull : book.citeAbbr

        if (chapter > 0 && book.numChapters > 0 && book.numChapters > 1) {
            title += " \(chapter)"
        }

        return title
    }
}