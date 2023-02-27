/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library gltf.extensions.msft_texture_dds;

import 'package:gltf/src/base/gltf_property.dart';
import 'package:gltf/src/ext/extensions.dart';

const String IMAGE_DDS = 'image/vnd-ms.dds';

const Extension msftTextureDDSExtension = Extension(
    'MSFT_texture_dds',
    <Type, ExtensionDescriptor>{
      Texture: ExtensionDescriptor(MsftTextureDdsTexture.fromMap)
    },
    init: _init);

void _init(Context context) {
  context.imageMimeTypes.add(IMAGE_DDS);
}

const List<String> MEMBERS = <String>[SOURCE];

class MsftTextureDdsTexture extends GltfProperty
    implements ResourceValidatable {
  final int _sourceIndex;

  Image _source;

  Image get source => _source;

  MsftTextureDdsTexture._(
      this._sourceIndex, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  static MsftTextureDdsTexture fromMap(
      Map<String, Object> map, Context context) {
    if (context.validate) {
      checkMembers(map, MEMBERS, context);
    }

    return MsftTextureDdsTexture._(
        getIndex(map, SOURCE, context, req: false),
        getExtensions(map, MsftTextureDdsTexture, context),
        getExtras(map, context));
  }

  @override
  void link(Gltf gltf, Context context) {
    _source = gltf.images[_sourceIndex];
    if (context.validate && _sourceIndex != -1) {
      if (_source == null) {
        context.addIssue(LinkError.unresolvedReference,
            name: SOURCE, args: [_sourceIndex]);
      } else {
        _source.markAsUsed();
      }
    }
  }

  @override
  void validateResources(Gltf gltf, Context context) {
    final mimeType = _source?.mimeType ?? _source?.info?.mimeType;
    if (mimeType != null && mimeType != IMAGE_DDS) {
      context
          .addIssue(LinkError.textureInvalidImageMimeType, name: SOURCE, args: [
        mimeType,
        const [IMAGE_DDS]
      ]);
    }
  }
}
