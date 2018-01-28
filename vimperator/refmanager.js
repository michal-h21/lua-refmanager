var PLUGIN_INFOx = xml`
  <VimperatorPlugin>
  <name>refmanager</name>
  <description lang="en">save web pages to the reference manager</description>
  <version>0.1.2</version>
  <minVersion>3.3</minVersion>
  <author mail="michal.h21@gmail.com" homepage="https://www.kodymirus.cz">Michal Hoftich</author>
  <updateURL></updateURL>
  <detail lang="en"><![CDATA[
    // TODO Documentation
  ]]></detail>
</VimperatorPlugin>`;

liberator.plugins.refmanager = (function(){
  function copy(that){
    var thisdocument = window.content.window.document;
    var inp =thisdocument.createElement('input');
    thisdocument.body.appendChild(inp)
    inp.value =that;
    inp.select();
    thisdocument.execCommand('copy',false);
    inp.remove();
  }

  function copypage(){
    var loc = window.content.window.location.href;
    var page = window.content.window.document.documentElement.outerHTML;
    var info = {url: loc, content: page};
    // var content = "---\n" + JSON.stringify(info) + "\n---\n" + page;
    var content = JSON.stringify(info);
    copy(content);
    console.log(content);
    // io.system("ls");
  }
  commands.addUserCommand(["trefmanager"], "refmanager", function(args){
    copypage();
  })
})();
