Contributing to DRLM
====================

How can I contribute?
---------------------

Reporting bugs
``````````````
Bug reports are submited through `GitHub Issues <https://guides.github.com/features/issues/>`_.

 * Use a clear and descriptive title
 * Describe the steps to reproduce the bug
 * Attach the logs
 * Describe the expected behaviour
 * Be as specific as possible
 * Specify which version of DRLM you're using
 * Specify which OS you're using (both the server and the client)

Fixing a bug
`````````
If you want to fix a bug, you have to follow this steps:

1. *Fork DRLM*

   First of all you need to Fork DRLM with your GitHub account

2. *Clone your fork of DRLM*

   Now you need to clone your DRLM fork:
   ``git clone https://github.com/<username>/drlm && cd drlm``

3. *Initialize Git Flow*

   Now you need to initialize Git Flow on your local repository:
   ``git flow init``

4. *Create the new branch*

   First you need to 
   After initializing Git Flow, you need to create the branch you are going to work with. The new version number is the same as the latest, but increasing by 1 the last number:
   ``git flow hotfix start <new.version.number>``

   For example, assuming latest version is 2.2.1:
   ``git flow hotfix start 2.2.2``

5. *Fix the bug*

   When commiting the changes, add a descriptive title and a brief description of what you have changed

6. *Make the Pull Request*

   When all you work is ready, you need to create the Pull Request. First you'll need to publish the branch:
   ``git flow hotfix publish``

   After publishing the branch, go to the `Brain Updaters DRLM repository <https://github.com/brainupdaters/drlm`_ and make a new Pull Request from your ``feature/<feature-name>`` branch of your fork to the ``develop`` branch. Don't worry, we'll change your Pull Request to the correct branch.You might need to click ``compare between forks``.

Suggesting new features or enhancements
```````````````````````````````````````
Suggestions are submited through `GitHub Issues <https://guides.github.com/features/issues/>`_.

 * Use a clear and descriptive title 
 * Explain with detail the feature/enhancements
 * Explain why the feature/enhancements would benefit the DRLM users

Adding a new functionality
`````````````````````
If you want to add new functionality, you have to follow this steps:

1. *Fork DRLM*

   First of all you need to Fork DRLM with your GitHub account

2. *Clone your fork of DRLM*

   Now you need to clone your DRLM fork:
   ``git clone https://github.com/<username>/drlm && cd drlm``

3. *Initialize Git Flow*

   Now you need to initialize Git Flow on your local repository:
   ``git flow init``

4. *Create the new branch*

   After initializing Git Flow, you need to create the branch you are going to work with:
   ``git flow feature start <feature-name>``

   Example:
   ``git flow feature start web-ui``

5. *Program the functionality*

   When commiting the changes, add a descriptive title and a brief description of what you have changed

6. *Make the Pull Request*

   When all you work is ready, you need to create the Pull Request. First you'll need to publish the branch:
   ``git flow feature publish``

   After publishing the branch, go to the `Brain Updaters DRLM repository <https://github.com/brainupdaters/drlm`_ and make a new Pull Request from your ``feature/<feature-name>`` branch of your fork to the ``develop`` branch. You might need to click ``compare between forks``.


Style guidelines
----------------

Git Flow
````````
DRLM follows a `Git Flow <https://danielkummer.github.io/git-flow-cheatsheet>`_ workflow. 

Semantic Versioning
```````````````````
DRLM uses `Semantic Versioning <https://semver.org>`_


Other
-----

Update your fork
````````````````
If you have already forked DRLM and you want to update your fork to match the upstream repository, you have to follow this steps:

1. Add the upstream as a Git remote

   Inside your repository, you need to add the upstream repository as a remote:
   ``git remote add upstream https://github.com/brainupdaters/drlm``

2. Fetch the latest changes

   Now you need to download the latest changes from the upstream repository
   ``git fetch upstream``

3. Merge the changes

   Finally, you need to merge the upstream changes to your repository. Keep in mind that the merge is specific depending on the branch you are:
   ``git merge upstream/<current-branch>``

   For example, assuming you are in the develop branch:
   ``git merge upstream/develop``

