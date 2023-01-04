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

    function procesTag({
        beforeBracketSpace,
        beforeNameSpace, 
        afterBracketSpace,
        afterNameSpace,
        // afterAttributeSpace,
        attributes,
        close,
        name,
    }) {
        let output = [];
        if (beforeBracketSpace) output = [...output, ...beforeBracketSpace]
        output.push({type: BRACKET, content: '<'})
        if (beforeNameSpace) output = [...output, ...beforeNameSpace]
        if (close !== null) output.push({type: BRACKET, content: '/'})
        if (name) output.push({type: TAG, content: name})
        if (exists(afterNameSpace)) output = [...output, ...afterNameSpace]
        if (exists(attributes)) output = [...output, ...attributes]
        // if (exists(afterAttributeSpace)) output = [...output, afterAttributeSpace]
        output.push({type: BRACKET, content: '>'})
        if (afterBracketSpace) output = [...output, ...afterBracketSpace]
        return output;
    }

}};

Expression = Comment / TagExpression;


TagExpression = 
open:OpenTag
    // enclosedString:ContentString
    contentNode:ContentNode*
close:CloseTag
{
    const openTagName = getTagContent(open);
    const closeTagName = getTagContent(close);
    if (openTagName !== closeTagName) { return null }
    // if (enclosedString.join('') === "") return [...open, ...close].flat();
    if (contentNode.join('') === "") return [...open, ...close].flat();
    // const content = {
    //     type: CONTENT, content: enclosedString.join('')
    // };
    return [...open, ...contentNode, ...close].flat();
    // return [...open, content, ...close].flat();
} / tag:Tag {
    const tagName = getTagContent(tag);
    if (singleTagsList.includes(tagName)) {
        return tag
    }
    return null;
}

ContentNode = 
    comment:Comment { return comment === null ? [] : comment } /
    //!'<!--' 
    contentString:ContentString {
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

// ContentString = [^<>]+ / "" { return text() };
ContentString = [^<>]+ { return text() };
// ContentString = !"<" !">" t:.+ { return t.join('')} / & "<" {return ''}
// Here is the problem of no compiling. Attempt to match '' or a non 
// input consuming operator is a disaster

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
    const result = [
        {type: COMMENT, content: `<!--${content.join('')}-->`}
    ];
    console.log('Comment', result)
    return result;
}

// Comment = '<!--' content:TextUntilCommentTermination '-->' {
//     return [
//         {type: COMMENT, content: `<!--${content}-->`}
//     ]
// }

TextUntilCommentTermination = content:(!CommentTerminationAhead .)* { return content.map(_ => _[1])}

CommentTerminationAhead = . ('-->')

Dash = [-_]+ { return text() }

Name = [a-zA-Z]+ { return text() };

_ "whitespace"
  = [ \t\n\r]*

// S = t:[\t] / n:[\n] / r:[\r] / s:[" "] {
//     if(n) return {
//         type: NEW_LINE,
//         content:'',
//     }
// }

S = space:[ \t\n\r] {
    if(space.match(/\n/)) return {
        type: NEW_LINE,
        content:'',
    }
    if(space === " ") return {
        type: SPACE,
        content: ' ',
    }
    if(space.match(/\t/)) return {
        type: TAB,
        content: "/t"
    }
    if(space.match(/\r/)) return {
        type: TAB,
        content: "/r"
    }

}

WhiteSpaces = whiteSpaces:S* {
    return whiteSpaces.reduce((acc, symb) => {
        if (symb) acc.push(symb)

        return acc;
    }, []);
}
