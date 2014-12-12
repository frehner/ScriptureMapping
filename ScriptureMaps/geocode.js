// Return the offset string for the current text selection.
function getSelectionOffset() {
    var node, range, selection, verse;

    if (window.getSelection) {
        selection = window.getSelection();

        if (selection.rangeCount) {
            range = selection.getRangeAt(0);
            node = range.startContainer;

            while (typeof(node) !== 'undefined' && node) {
                // Look for parent node that has the verse number
                if (node.tagName === 'A' && typeof(node.getAttribute('name')) !== 'undefined' &&
                    node.getAttribute('name') !== null) {
                    // We found a verse number, so that's enough to identify the offset
                    return node.getAttribute('name') + "@" + range.startOffset;
                }

                node = node.parentNode;
            }

            // If verse number not found, send Xpath
            return getNodeXPath(range.startContainer) + "@" + range.startOffset;
        }
    }

    // Something went horribly wrong (http://xkcd.com/1047/)
    return "";
}

// See http://stackoverflow.com/questions/3454526
var getNodeXPath = function(node) {
    if (node && node.id)
        return '//*[@id="' + node.id + '"]';
    else
        return getNodeTreeXPath(node);
};

var getNodeTreeXPath = function(node) {
    var paths = [];

    // Use nodeName (instead of localName) so namespace prefix is included (if any).
    for (; node && (node.nodeType == 1 || node.nodeType == 3) ; node = node.parentNode)  {
        var index = 0;
        // EXTRA TEST FOR ELEMENT.ID
        if (node && node.id) {
            paths.splice(0, 0, '/*[@id="' + node.id + '"]');
            break;
        }

        for (var sibling = node.previousSibling; sibling; sibling = sibling.previousSibling) {
            // Ignore document type declaration.
            if (sibling.nodeType == Node.DOCUMENT_TYPE_NODE)
                continue;

            if (sibling.nodeName == node.nodeName)
                ++index;
        }

        var tagName = (node.nodeType == 1 ? node.nodeName.toLowerCase() : "text()");
        var pathIndex = (index ? "[" + (index+1) + "]" : "");
        paths.splice(0, 0, tagName + pathIndex);
    }

    return paths.length ? "/" + paths.join("/") : null;
};