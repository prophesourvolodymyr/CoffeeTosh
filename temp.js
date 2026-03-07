      const bodyCenterZ = (bodyBox.min.z + bodyBox.max.z) * 0.5;
      const hingeZ = lidCenterZ >= bodyCenterZ ? bodyBox.max.z : bodyBox.min.z;
      const hingeWorld = new THREE.Vector3(
        (lidBox.min.x + lidBox.max.x) / 2,
        bodyBox.max.y,
        hingeZ
      );
      console.log('[GLB] hinge(world)', hingeWorld.toArray());

      /* Pivot-group with world-transform preservation. */
      lidPivot = new THREE.Group();
      lidPivot.position.copy(model.worldToLocal(hingeWorld.clone()));
      LID_PIVOT_Y0 = lidPivot.position.y;
      model.add(lidPivot);
      model.updateMatrixWorld(true);
      lidPivot.attach(lidNode);
      model.updateMatrixWorld(true);
      console.log('[GLB] pivot(local)', lidPivot.position.toArray());

      /* The model is actually modeled completely closed.
         Therefore, its initial rotation (0) is perfectly flat/closed. */
      LID_CLOSE_ANGLE = 0;
      LID_CLOSE_Y_OFFSET = 0;
      lidPivot.position.y = LID_PIVOT_Y0;

      /* Determine open direction. We are at 0 (closed). 
         Let's find a point on the lid far from the hinge (e.g., the front edge). */
      lidPivot.rotation.x = 0;
      model.updateMatrixWorld(true);
      var closedLidBox = new THREE.Box3().setFromObject(lidNodeRef);
      var frontPointWorld = new THREE.Vector3(
        (closedLidBox.min.x + closedLidBox.max.x) / 2,
        (closedLidBox.min.y + closedLidBox.max.y) / 2,
        hingeWorld.z > closedLidBox.min.z ? closedLidBox.min.z : closedLidBox.max.z 
        // Picks the Z extreme furthest from the hinge (which is the front lip)
      );
      var frontPointLocal = lidNodeRef.worldToLocal(frontPointWorld.clone());

      /* Rotate slightly and see which direction moves the front lip UP. */
      lidPivot.rotation.x = +0.1;
      model.updateMatrixWorld(true);
      var tipUpPlus = lidNodeRef.localToWorld(frontPointLocal.clone()).y;

      lidPivot.rotation.x = -0.1;
      model.updateMatrixWorld(true);
      var tipUpMinus = lidNodeRef.localToWorld(frontPointLocal.clone()).y;

      /* Whichever rotation raised the lip higher is the opening direction. */
      var openSign = (tipUpPlus > tipUpMinus) ? 1 : -1;
      
      // Open to about 115 degrees (approx 2.0 radians)
      LID_OPEN_ANGLE = openSign * 2.0;

      console.log('[GLB] Models starts closed. Open Sign:', openSign, 'Open Angle:', LID_OPEN_ANGLE);

      /* Reset to open pose — animation starts from here. */
      lidPivot.rotation.x = LID_OPEN_ANGLE;
      lidPivot.position.y = LID_PIVOT_Y0;
      console.log('[GLB] closeSign', closeSign, 'openAngle', LID_OPEN_ANGLE.toFixed(3), 'closeAngle', LID_CLOSE_ANGLE.toFixed(4));

      /* ── Video texture on the screen panel ── */
      screenCandidate = null;
      var bestArea = 0;
      lidNode.traverse(function(child) {
        if (!child.isMesh) return;
        var b = new THREE.Box3().setFromObject(child);
        var sz = b.getSize(new THREE.Vector3());
        var dims = [sz.x, sz.y, sz.z].sort(function(a, b) { return b - a; });
        var area = dims[0] * dims[1];
        if (area > bestArea && dims[2] < dims[0] * 0.15) {
          bestArea = area;
          screenCandidate = child;
        }
