{{
    import { 
        TAG, PARAM, QUOTED, COMMENT, BRACKET, NEW_LINE, CONTENT, ASSIGN, SPACE, VAL,
        R, TAB,
    } from "../constants/htmlColors.js";

    const singleTagsList = ['br', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

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

Expression = Comment / TagExpression;


TagExpression = 
open:OpenTag
    contentNode:ContentNode*
close:CloseTag
{
    const openTagName = getTagContent(open);
    const closeTagName = getTagContent(close);
    if (openTagName !== closeTagName) { return null }
    if (contentNode.join('') === "") return [...open, ...close].flat();
    return [...open, ...contentNode, ...close].flat();
} / tag:Tag {
    const tagName = getTagContent(tag);
    if (singleTagsList.includes(tagName)) {
        return tag
    }
    return null;
}

ContentNode = 
        nl1:NewLine*
        comment:Comment
        nl2:NewLine*
        { return comment === null ? [] : comment }
    /
        nl3:NewLine*
        contentString:ContentString
        nl4:NewLine*
        {
            console.log('ContentNode', contentString)
            if (contentString === '') return [];
            return [{ type: CONTENT, content: contentString}]
        } 


OpenTag = 
    beforeBracketSpace:WhiteSpaces 
    "<" !'!'
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
    close:"/"? 
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

Tag = open:OpenTag { return open } / close:CloseTag { return close }

ContentString = [^<>]+ { return text() };

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

TextUntilCommentTermination = content:(!CommentTerminationAhead .)* { return content.map(_ => _[1])}

CommentTerminationAhead = . ('-->')

Dash = [-_]+ { return text() }

Name = [a-zA-Z]+ { return text() };

_ "whitespace"
  = [ \t\n\r]*

NewLine = [\n] {
    return {
        type: NEW_LINE,
        content: '',
    }
}

S = space:[ \t\n\r] {
    if(space.match(/\n/)) return getNewLine();
    if(space === " ") return getSpace();
    if(space.match(/\t/)) return getTabulation();
    if(space.match(/\r/)) return getReturnC();
}

WhiteSpaces = whiteSpaces:S* {
    return whiteSpaces.reduce((acc, symb) => {
        if (symb) acc.push(symb)

        return acc;
    }, []);
}
