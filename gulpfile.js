var gulp = require('gulp');
var del = require('del');
var shell = require('shelljs');
var bump = require('gulp-bump');
var util = require('util');

var config = {
    wowAddonDir: 'C:/Program Files (x86)/World of Warcraft/Interface/AddOns/StatWeightScore',
    src: 'src/**/*.{lua,xml,toc}'
};

gulp.task('clean-local', function(cb){
    del([util.format('%s/**/*', config.wowAddonDir)], { force: true }, cb);
})

gulp.task('publish-local', ['clean-local'], function(){
    return gulp
        .src(config.src)
        .pipe(gulp.dest(config.wowAddonDir));
});

gulp.task('watch', ['publish-local'], function(){
    gulp.watch(config.src, ['publish-local'])
});

gulp.task('_bump', function(){
    var argv = require('yargs')
        .alias('v', 'version')
        .alias('t', 'type')
        .check(function(argv){
            if((!argv.version && !argv.type) || (argv.version && argv.type)){
                throw 'Exactly one of version or type arguments is required';
            }

            return true;
        })
        .argv;
        
    var bumpOptions = {
        preid: 'rc'
    };
    
    if(argv.version){
        bumpOptions.version = argv.version;
    } else if(argv.type){
        bumpOptions.type = argv.type;
    }
    
    return gulp
        .src('package.json')
        .pipe(bump(bumpOptions))
        .pipe(gulp.dest('.'));
});

gulp.task('release', ['_bump'], function(){
    var version = require('./package.json').version;
    
    shell.exec(util.format('git commit -a -m "Release v%s"', version));
    shell.exec(util.format('git tag %s', version));
    shell.exec('git push origin master');
    
    console.log(util.format('Release %s completed', version));
});