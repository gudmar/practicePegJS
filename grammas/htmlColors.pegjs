//  TypeError: Cannot read property 'split' of null
//     at /home/witold/.nvm/versions/node/v14.15.5/lib/node_modules/peggy/lib/grammar-error.js:86:18
//     at Array.map (<anonymous>)
//     at GrammarError.format (/home/witold/.nvm/versions/node/v14.15.5/lib/node_modules/peggy/lib/grammar-error.js:84:30)
//     at PeggyCLI.error (/home/witold/.nvm/versions/node/v14.15.5/lib/node_modules/peggy/bin/peggy-cli.js:355:45)
//     at PeggyCLI.main (/home/witold/.nvm/versions/node/v14.15.5/lib/node_modules/peggy/bin/peggy-cli.js:630:12)
//     at processTicksAndRejections (internal/process/task_queues.js:93:5)
// Waiting for the debugger to disconnect...

// Most probably caused by the fact, that I do:
// SomeTag = n:Node*
// Node = t:Tag*
// In such gramma if no Node matched, null returned, then null passed to SomeTag and split with * cannot be done
// If 
// SomeTag = n:Node*
// Node = t:Tag+
// Then works, because it is promissed that at least one element will be present

// And the construction with double * is not needed. * + does the job, as 
// first one is capable of reducing nr of + to 0


{{
    import { 
        TAG, PARAM, QUOTED, COMMENT, BRACKET, NEW_LINE, CONTENT, ASSIGN, SPACE, VAL,
        R, TAB,
    } from "../constants/htmlColors.js";

    function getTagContent(parsedResult){
        const result = parsedResult.find((item) => item.type === TAG)
        return result?.content;
    }

    function exists(param) {
        return (param && Array.isArray(param) && param.length > 0)
    }

    function concatTail(tail) {
        const result = tail.reduce((acc, item) => {
            acc = `${acc}${item.join('')}`
            return acc;
        }, '')
        return result;
    }

    function getTextContent(txt) {
        return {
            content: txt,
            type: CONTENT,
        }
    }
    function getNewLine() { return {type: NEW_LINE, content:''} }
    function getLt() { return { type: BRACKET, content: '<'} }
    function getGt() { return { type: BRACKET, content: '>'} }
    function getSlash() { return { type: BRACKET, content: '/'} }
    function getTag(tag) { 
        if (!tag) return null;
        return { type: TAG, content: tag} 
    }
    function getComment(content) { return {type: COMMENT, content: `<!--${content.join('')}-->`} }
    function getSpace() { return { type: SPACE, content: ' '}}
    function getTabulation() { return { type: TAB, content: '/t'}}
    function getReturnC() { return { type: TAB, content: '/r'}}

    function buildParseArray(arr) {
        const result = arr.reduce((acc, item) => {
            if (exists(item)) {
                acc = [ ...acc, ...item ]
                return acc;
            }
            if (!Array.isArray(item) && item) { acc.push(item)}
            return acc;
        }, [])
        return result;
    }

    function procesTag({
        beforeBracketSpace,
        beforeNameSpace, 
        afterBracketSpace,
        afterNameSpace,
        attributes,
        close,
        name,
    }) {
        const result = buildParseArray([
            beforeBracketSpace,
            getLt(),
            beforeNameSpace,
            close ? getSlash() : null,
            getTag(name),
            afterNameSpace,
            attributes,
            getGt(),
            afterBracketSpace,
        ])
        return result
    }
}};

Document = n:Node* {
    const result = buildParseArray(n);
    return result;
}

Node = txt:Text+ {
    const result = buildParseArray(txt);
    return result;
} / branch:Branch+ {
    const result = buildParseArray(branch);
    return result;
} / single: SingleTag+ {
    const result = buildParseArray(single);
    return result;
} / comment:Comment+ {
    const result = buildParseArray(comment);
    return result;
} / SpaceOrMore

Branch = 
    open:OpenTag
        node:Document?
    close:CloseTag {
        const openTagName = getTagContent(open);
        const closeTagName = getTagContent(close);
        if (openTagName !== closeTagName) { return [] }
        if (!node) return [...open, ...close].flat();
        // if (node.join('') === "") return [...open, ...close].flat();
        return [...open, ...node, ...close].flat();
    }

SingleTagNames = 'br' / 'hr' / 'img' / 'input' / 'keygen' / 'link' / 
    'meta' / 'param' / 'source' / 'track' / 'wbr'

SingleTag = 
    '<'
    close:'/'?
    name:SingleTagNames
    afterNameSpace:WhiteSpaces 
    attributes:AttributeChainElement*
    '>'
    {
    return buildParseArray([
        getLt(),
        close ? getSlash() : null,
        getTag(name),
        afterNameSpace,
        attributes,
        getGt()
    ].flat())
}

OpenTag = 
    beforeBracketSpace:WhiteSpaces 
    "<" !'!'
    !SingleTagNames
    beforeNameSpace:WhiteSpaces 
    openTagName:Name? 
    afterNameSpace:WhiteSpaces 
    attributes:AttributeChainElement*
    ">" 
    afterBracketSpace:WhiteSpaces 
    {
        const openTag = procesTag({
            beforeBracketSpace,
            beforeNameSpace,
            afterBracketSpace,
            afterNameSpace,
            attributes,
            close: null,
            name: openTagName,
        });
        console.log('OpenTag', openTag)
        return openTag;
    }

CloseTag = 
    beforeBracketSpace:WhiteSpaces 
    "<" !"!"
    beforeNameSpace:WhiteSpaces 
    close:"/" 
    !SingleTagNames
    closeTagName:Name? 
    ">" 
    afterBracketSpace:WhiteSpaces 
    {
        const closeTag = procesTag({
            beforeBracketSpace,
            beforeNameSpace,
            afterBracketSpace,
            close,
            name: closeTagName,
        })
        console.log('CloseTag', closeTag)
        return closeTag;
    }

AttributeChainElement = attr:Attribute space:WhiteSpaces? {
    let result = [...attr];
    if (exists(space)) result = [...result, ...space]
    return result;
}

Attribute = name:AttributeName value:AttributeTail? {
    let output = [{
        type: PARAM,
        content: name
    }]
    if(exists(value)) output = [...output, ...value].flat();
    return output;
}

AttributeTail = afterAttributeSpace:WhiteSpaces? "=" beforeValueSpace:WhiteSpaces? value:AttributeValue {
    let output = []
    if (afterAttributeSpace && exists(afterAttributeSpace)) { output = [...output, afterAttributeSpace].flat()}
    output.push({type:ASSIGN, content: "="});
    if (beforeValueSpace && exists(beforeValueSpace)) { output = [...output, beforeValueSpace].flat()}
    if (value) { output.push({
        type: VAL,
        content: value,
    })}
    return output
}

Text = txt:([^\n<>]+ {return text()}) { return getTextContent(txt)}

AttributeName = predecator:Name tail:(Dash AttributeNameTail)* {
    const concatenatedTail = concatTail(tail)
    return `${predecator}${concatenatedTail}`
}

AttributeNameTail = [a-zA-Z0-9]* { return text() }

AttributeValue = 
    StringSingleQuoted / 
    StringDoubleQuoted / 
    StringTemplateQuoted /
    FloatingPointNumber /
    "true" / 
    "false"

StringSingleQuoted = "'" val:[^']* "'" { return val.join('') }

StringDoubleQuoted = '"' val:[^"]* '"' { return val.join('') }

StringTemplateQuoted = '`' val:[^`]* '`' { return val.join('') }

FloatingPointNumber = int:[0-9] tail:(FloatingPointTail)? {
    return `${int}${tail?tail:''}`
}

FloatingPointTail = dot:[.] fraction:[0-9]+ {
    return `${dot?'.':''}${fraction?fraction.join(''):''}`
}

Comment = '<!--' content:(!"-->" i:. {return i})* '-->' {
    const result = [ getComment(content) ];
    console.log('Comment', result)
    return result;
}

Dash = [-_]+ { return text() }

Name = chars:[a-zA-Z]+ { return text() };

Space = space:[ \t\n\r] {
    if(space.match(/\n/)) return getNewLine();
    if(space === " ") return getSpace();
    if(space.match(/\t/)) return getTabulation();
    if(space.match(/\r/)) return getReturnC();
    console.error('Spaces: no pattern matched');
}

WhiteSpaces = whiteSpaces:Space* {
    const result = buildParseArray(whiteSpaces);
    return result;
}

SpaceOrMore = whiteSpaces:Space+ {
    const result = buildParseArray(whiteSpaces);
    return result;
}
