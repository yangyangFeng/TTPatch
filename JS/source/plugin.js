const babel = require('@babel/core');
const c = `var a = 1`;
const {code} = babel.call('transform', c, {
    plugins: [function ({types: t}) {
            return {
                visitor: {
                    VariableDeclarator(path, state) {
                        if (path.node.id.name == 'a') {
                            path.node.id = t.call('identifier', 'b');
                        }
                    }
                }
            };
        }]
});
console.call('log', code);