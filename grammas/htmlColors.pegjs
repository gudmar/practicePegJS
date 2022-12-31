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
        afterAttributeSpace,
        attribute,
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
        if (exists(attribute)) output = [...output, ...attribute]
        if (exists(afterAttributeSpace)) output = [...output, afterAttributeSpace]
        output.push({type: BRACKET, content: '>'})
        if (afterBracketSpace) output = [...output, ...afterBracketSpace]
        return output;
    }

}};


TagExpression = 
open:OpenTag
    enclosedString:ContentString
close:CloseTag
{
    const openTagName = getTagContent(open);
    const closeTagName = getTagContent(close);
    if (openTagName !== closeTagName) { return null }
    if (enclosedString.join('') === "") return [...open, ...close].flat();
    const content = {
        type: CONTENT, content: enclosedString.join('')
    };
    return [...open, content, ...close].flat();
} / tag:Tag {
    const tagName = getTagContent(tag);
    if (singleTagsList.includes(tagName)) {
        return tag
    }
    return null;
}

OpenTag = 
    beforeBracketSpace:WhiteSpaces 
    "<" 
    beforeNameSpace:WhiteSpaces 
    openTagName:Name? 
    afterNameSpace:WhiteSpaces 
    attribute:Attribute?
    afterAttributeSpace:WhiteSpaces
    ">" 
    afterBracketSpace:WhiteSpaces 
    {
        const openTag = procesTag({
            beforeBracketSpace,
            beforeNameSpace,
            afterBracketSpace,
            afterNameSpace,
            afterAttributeSpace,
            attribute,
            close: null,
            name: openTagName,
        });
        return openTag;
    }

CloseTag = beforeBracketSpace:WhiteSpaces "<" beforeNameSpace:WhiteSpaces close:"/"? closeTagName:Name? ">" afterBracketSpace:WhiteSpaces {
    const closeTag = procesTag({
        beforeBracketSpace,
        beforeNameSpace,
        afterBracketSpace,
        close,
        name: closeTagName,
    })
    return closeTag;
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

// Tag = TagBracket TagBracket / 
//       TagBracket name:Name _ attr:Attribute* TagBracket {
//         console.log('Tag', name, attr)
//         const output = [];
//         if (name) output.push({
//             type: TAG,
//             content: name,
//         })
//         if (attr) output.push({
//             type: PARAM,
//             content: attr,
//         })
//         return output;
//       }

// Attribute = attName:Name { return text() }
// // Attribute = attName:Name _ val:( _ Assign _ Value?) {

// // }

// TagBracket = ob:'<' / cb:'>' / cl: '<' _ '/' {
//     console.log('TagBracket', ob, cb, cl)
//     if (cl) {
//         return [
//            { type: BRACKET, content: '<' },
//            { type: BRACKET, content: '/' }
//         ]
//     }
//     return [{
//         type: BRACKET,
//         content: ob | cb
//     }]
// }

// // Value = String / Boolean { return text() }

// // String = "\""str:StrText"\"" / "\'"str1:StrText"\'" / "\`"str2:StrText"\"" {
// //     console.log('String', str, str1, str2)
// //     return text();    
// // }

// // StrText = [.]* { 
// //     console.log('String', text())
// //     return text() 
// // }

// // Boolean = "true" / "false" {  
// //     console.log('boolean', text())
// //     return text() 
// // }

// Assign = '=' { return text() }

ContentString = [^<>]* / "" { return text() };

AttributeName = predecator:Name tail:(Dash AttributeNameTail)* {
    const concatenatedTail = concatTail(tail)
    return `${predecator}${concatenatedTail}`
}

AttributeNameTail = [a-zA-Z0-9]* { return text() }

// AttributeValue = 
//     // "\"" (.)* "\"" / 
//     (a:"\'" b:[^/']* c:"\'") {
//         const t = a + b + c;
//         return t;
//     }
//     //  / 
//     // "\`" (.)* "\`" / 
//     // "true" / 
//     // "false" / 
//     // [0-9] ("." [0-9])? { return text() }
AttributeValue = StringSingleQuoted / StringDoubleQuoted / StringTemplateQuoted / "true" / "false"

StringSingleQuoted = "'" val:[^']* "'" { return val.join('') }

StringDoubleQuoted = '"' val:[^"]* '"' { return val.join('') }

StringTemplateQuoted = '`' val:[^`]* '`' { return val.join('') }

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
