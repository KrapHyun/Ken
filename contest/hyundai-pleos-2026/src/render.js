const {chromium}=require('playwright');
(async()=>{const b=await chromium.launch();const p=await b.newPage({deviceScaleFactor:2,viewport:{width:1200,height:800}});
for(const f of ['fig1','fig2','fig3','fig4']){await p.goto('file://'+__dirname+'/'+f+'.html');await p.waitForTimeout(300);
await p.setViewportSize({width:1200,height:100});const el=await p.$('body');await el.screenshot({path:process.argv[2]+'/'+f+'.png'});}
await b.close();})();
