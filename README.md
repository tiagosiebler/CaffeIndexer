# CaffeIndexer

Loop through and attempt to classify an unknown collection of images representing (mostly) playing cards, while identifying images that are either part of the table, or considered 'noise' (e.g unfinished animations at the time of image capture). Manually sifting through these unknown images was too inefficient a process for a task that needed to be done regularly. This was my successful attempt at automating the bulk of that process.

While this is too slow to be used in a live scenario, where time is limited, it can be used to build a dictionary of known images that can be later compared to at runtime. If the live data doesn't change often, this can be an effective method of identifying images at consistent coordinates (e.g cards on a poker table). 

## Workflow
1. The unknown images in one folder. The contents of that folder is used as a list of unknown images. The loop cycles through each image in this list.
2. The analyseImageAtPath: method is called on each image. This builds and executes a command-line call to the caffe clasifier, passing the paths of the image and the Caffe model files.
3. The handleCardWithString:andAccuracy:andPath method is called with the result from the classifier execution. 
4. Matches with less than 90% confidence are ignored for manual processing. Anything else is organised into subfolders based on the top match from the classifier.
5. During the move, high-confidence matches are renamed based on a hashed value corresponding to the NSData of the NSImage. 

This hashing method can be used to late recognise live images with enough similarity. 

## Dependencies
- A trained Caffe model (not included right now).
- The Caffe classifier, compiled as a standalone binary: https://github.com/tiagosiebler/CaffeClassifierMac

## Footnotes
The code is not as clean and efficient as it could be. There is much room for improvement, but it serves its purpose.

