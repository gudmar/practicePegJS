export class Helper {
    constructor({
        getTokenType
    }){
        this.getTokenType = getTokenType;
    }

    static get EXPRESSION() { return 'Expressoin'; }
    static get TERM()       { return 'Term'; }
    static get PLUS()       { return 'Plus'; }
    static get MINUS()      { return 'Minus'; }
    static get FACTOR()     { return 'Factor'; }
    static get MULTI()      { return 'Multi'; }
    static get DIV()        { return 'Div'; }
    static get NUMBER()     { return 'Number'; }
    static get OB()         { return 'OB'; }
    static get CB()         { return 'CB'; }

    static terminalTypes() {
        return [
            Helper.OB, Helper.CB, Helper.PLUS, Helper.MINUS, Helper.MULTI, Helper.DIV, Helper.NUMBER
        ]
    }

    static getTokenType(token) {
        const isNotNan = !isNaN(parseFloat(token));
        if (isNotNan) return HELPER.NUMBER;
        const grammaTypes = [Helper.EXPRESSION, Helper.TERM, Helper.FACTOR]
        switch(token) {
            case '(':     return Helper.OB;
            case ')' :    return Helper.CB;
            case '-' :    return Helper.MINUS;
            case '+' :    return Helper.PLUS;
            case '*' :    return Helper.MULTI;
            case '/' :    return Helper.DIV;
            default: {
                if (grammaTypes.find(_ => token === _) !== undefined) return token
                if (Helper.terminalTypes().includes(token)) return token;
                throw new Error(`Token ${token} not recognized`);
            }
        }
    }

    getToken(token){
        return {
            type: this.getTokenType(token),
            // toParse: token,
            value: [token],
        }
    }
    toParse(tokens) {
        return tokens.map(item => (item.toParse !== undefined ? item.toParse : `${item}`)).join(' ')
    }
    wrap({ type, valueArray }){
        return {
            type,
            // toParse: this.toParse(valueArray),
            value: valueArray,
        }
    }

    nest({ types, valueArray }){
        if (!Array.isArray(types)) throw new Error('Helper.nest: types shoudl be an array');
        if (!Array.isArray(valueArray)) throw new Error('Helper.nest: valueArray should be an array');
        if (types.length < 1 || valueArray < 1) throw new Error('Helper.nest: types and valueArray should have length >= 1')
        const result = types.reverse().reduce(
            (acc, type, index) => {
                if (index === 0) return acc;
                acc = {
                    type: type,
                    // toParse: this.toParse(valueArray),
                    value: [acc]
                }
                return acc;
            }, this.wrap({ type: types[0], valueArray })
        )
        return result;
    }

    isPrimitive(x){
        return [
            typeof 8,
            typeof '3',
            typeof true,
            typeof 3n,
            typeof undefined,
            typeof Symbol('x')
        ].includes(typeof x);
    }

    getListOfTokens(tokens){
        return tokens.map(token => {
            return this.isPrimitive(token) ?
            this.getToken(token) :
            token;
        });
    }
}

export const isTerminal = (token) => {
    if(!isNaN(parseFloat(token))) return true;
    const terminals = ['*', '(', ')', '+', '-', '/', 'if', '>'];
    return terminals.find(t => t === token.value)
}

export const isTypeTerminal = (type) => {
    const terminals = [
        tokenTypes.MULTI, 
        tokenTypes.OB,
        tokenTypes.CB,
        tokenTypes.PLUS,
        tokenTypes.MINUS,
        tokenTypes.DIV,
        tokenTypes.IF,
        tokenTypes.GT,
        tokenTypes.NUMBER,
        tokenTypes.IF,
        tokenTypes.THEN,
    ];
    return terminals.find(t => t === type) !== undefined;
}


export const getTokenType = (token) => {
    if(!isNaN(parseFloat(token))) return 'number'
    switch(token){
        case '*': return tokenTypes.MULTI;
        case '+': return tokenTypes.PLUS;
        case '-': return tokenTypes.MINUS;
        case '/': return tokenTypes.DIV;
        case ')': return tokenTypes.CB;
        case '(': return tokenTypes.OB;
        case 'if': return tokenTypes.IF;
        case '>': return tokenTypes.GT;
        case 'then': return tokenTypes.THEN;
        default: throw `Token ${token} not found`
    }
}

export const tokenTypes = {
    EXPRESSION: 'expression',
    FRACTION: 'fraction',
    FACTOR: 'factor',
    TERM: 'term',
    MULTI: 'multi',
    PLUS: 'plus',
    MINUS: 'minus',
    DIV: 'div',
    PRODUCT: 'product',
    SUM: 'sum',
    NUMBER: 'number',
    OB: 'openBracket',
    CB: 'closeBracket',
    GT: 'greaterThen',
    IF: 'if'
}
