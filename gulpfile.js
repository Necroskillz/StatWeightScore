var gulp = require('gulp');
var del = require('del');
var util = require('util');

var config = {
    wowAddonDir: 'C:/Program Files (x86)/World of Warcraft/Interface/AddOns/StatWeightScore',
    src: 'src/**/*.{lua,xml,toc}'
};

gulp.task('clean-local', function(cb){
    del([util.format('%s/**/*', config.wowAddonDir)], { force: true }, cb);
});

gulp.task('clean-dist', function(cb){
   del(['dist/**/*'], { force: true }, cb); 
});

gulp.task('publish-local', ['clean-local'], function(){
    return gulp
        .src(config.src)
        .pipe(gulp.dest(config.wowAddonDir));
});

gulp.task('publish-dist', ['clean-dist'], function(){
    return gulp
        .src([config.src, '!src/libs/**/!(libs.xml)', '!src/localization/*.debug.lua', '.pkgmeta', 'CHANGELOG.txt'])
        .pipe(gulp.dest('dist'));
});

gulp.task('watch', ['publish-local'], function(){
    gulp.watch(config.src, ['publish-local'])
});