var logger = require('jsdoc/util/logger');

exports.defineTags = function (dictionary) {
    dictionary.defineTag('category', {
        mustHaveValue: true,
        onTagged: function (doclet, tag) {
            const category = tag.value;
            if (!category) return;
            if (env.conf.categories[category]) {
                doclet.category = category;
            } else {
                logger.error(`Undefined category "${category}"`);
            }
        }
    });
};

exports.handlers = {
    beforeParse: function () {
        loadConfiguration();
    }
};

function loadConfiguration() {
    try {
        const fs = require('jsdoc/fs');
        const confFileContents = fs.readFileSync(env.conf.categoriesFile, 'utf8');
        env.conf.categories = JSON.parse(confFileContents || '{}');
        env.conf.categoryList = Object.keys(env.conf.categories);
    } catch (e) {
        throw 'Could not load category file';
    }
}

exports.getMembers = (data, category) => {
    const doclets = data({ category: category }).get();
    return doclets;
};
