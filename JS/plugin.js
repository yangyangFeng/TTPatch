const  babel = require('@babel/core');
// const esprima = require('esprima');
const c = `var a = 1`;

const { code } = babel.transform(c, {
	plugins: [
		function({ types: t }) {
			return {
				visitor: {
					VariableDeclarator(path, state) {
						if (path.node.id.name == 'a') {
							path.node.id = t.identifier('b')
						}
					}
				}
			}
		}
	]
})

console.log(code); // var b = 1